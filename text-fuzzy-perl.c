#define NO_MAX_DISTANCE -1

/* Get memory via Perl. */

#define get_memory(value, number, what) {                       \
        Newxz (value, number, what);                            \
        if (! value) {                                          \
            croak ("%s:%d: "                                    \
                   "Could not allocate memory for %d %s",       \
                   __FILE__, __LINE__, number, #what);          \
        }                                                       \
        text_fuzzy->n_mallocs++;                                \
    }

int perl_error_handler (const char * file_name, int line_number,
                        const char * format, ...)
{
    va_list a;
    warn ("%s:%d: ", file_name, line_number);
    va_start (a, format);
    vwarn (format, & a);
    va_end (a);
    return 0;
}

#define SMALL 0x1000
#define HUGEBUGGY (SMALL * SMALL)

/* Decide what length to make "text_fuzzy->b.unicode". It has to be
   bigger than "minimum". */

static void fake_length (text_fuzzy_t * text_fuzzy, int minimum)
{
    int r = SMALL;
 again:
    if (minimum < r) {
	text_fuzzy->b_unicode_length = r;
	return;
    }
    r *= 2;
    if (r > HUGEBUGGY) {
	croak ("String length %d longer than maximum allowed for, %d.\n",
	       minimum, HUGEBUGGY);
    }
    goto again;
}

/* Allocate the memory for b. */

static void allocate_b_unicode (text_fuzzy_t * text_fuzzy, int b_length)
{

    if (! text_fuzzy->b.unicode) {

	/* We have not allocated any memory yet. */

	fake_length (text_fuzzy, b_length);
	get_memory (text_fuzzy->b.unicode,
		    text_fuzzy->b_unicode_length, int);
    }
    else if (b_length > text_fuzzy->b_unicode_length) {

	/* "b" is bigger than what we allowed for. */

	fake_length (text_fuzzy, b_length);
	Renew (text_fuzzy->b.unicode, text_fuzzy->b_unicode_length, int);
    }
}

/* Given a Perl string in "text" which is marked as being Unicode
   characters, use the Perl stuff to turn it into a string of
   integers. */

static void sv_to_int_ptr (SV * text, text_fuzzy_string_t * tfs)
{
    int i;
    U8 * utf;
    STRLEN curlen;
    STRLEN length;
    unsigned char * stuff;

    stuff = (unsigned char *) SvPV (text, length);

    utf = stuff;
    curlen = length;
    for (i = 0; i < tfs->ulength; i++) {
        STRLEN len;

	/* The documentation for "utf8n_to_uvuni" can be found in
	   "perldoc perlapi". There is an online version here:
	   "http://perldoc.perl.org/perlapi.html#Unicode-Support". */

        tfs->unicode[i] = utf8n_to_uvuni (utf, curlen, & len, 0);
        curlen -= len;
        utf += len;
    }
}

/* Convert a Perl SV into the text_fuzzy_t structure. */

static void
sv_to_text_fuzzy (SV * text, int max_distance,
                  text_fuzzy_t ** text_fuzzy_ptr)
{
    STRLEN length;
    unsigned char * stuff;
    text_fuzzy_t * text_fuzzy;
    int i;
    int is_utf8;

    /* Allocate memory for "text_fuzzy". */
    get_memory (text_fuzzy, 1, text_fuzzy_t);
    text_fuzzy->max_distance = max_distance;

    /* Copy the string in "text" into "text_fuzzy". */
    stuff = (unsigned char *) SvPV (text, length);
    text_fuzzy->text.length = length;
    get_memory (text_fuzzy->text.text, length + 1, char);
    for (i = 0; i < length; i++) {
        text_fuzzy->text.text[i] = stuff[i];
    }
    text_fuzzy->text.text[text_fuzzy->text.length] = '\0';
    is_utf8 = SvUTF8 (text);
    if (is_utf8) {

	/* Put the Unicode version of the string into
	   "text_fuzzy->text". */

        text_fuzzy->unicode = 1;
	text_fuzzy->text.ulength = sv_len_utf8 (text);

	get_memory (text_fuzzy->text.unicode, text_fuzzy->text.ulength, int);

	sv_to_int_ptr (text, & text_fuzzy->text);

	/* Generate the Unicode alphabet. */

	TEXT_FUZZY (generate_ualphabet (text_fuzzy));
    }
    else {
	TEXT_FUZZY (generate_alphabet (text_fuzzy));
    }
    * text_fuzzy_ptr = text_fuzzy;
}

/* The following palaver is related to the macros "FAIL" and
   "FAIL_MSG" in "text-fuzzy.c.in". */

#undef FAIL_STATUS
#define FAIL_STATUS -1

static void
sv_to_text_fuzzy_string (SV * word, text_fuzzy_t * tf)
{
    STRLEN length;
    tf->b.text = SvPV (word, length);
    tf->b.length = length;
    if (SvUTF8 (word) || tf->unicode) {

	/* Make a Unicode version of b. */

	tf->b.ulength = sv_len_utf8 (word);
	allocate_b_unicode (tf, tf->b.ulength);
	sv_to_int_ptr (word, & tf->b);
    }
}

static int
text_fuzzy_sv_distance (text_fuzzy_t * tf, SV * word)
{
    sv_to_text_fuzzy_string (word, tf);
    TEXT_FUZZY (compare_single (tf));
    if (tf->found) {
        return tf->distance;
    }
    else {
        return tf->max_distance + 1;
    }
}

/* Initialize tf for a search over an array. */

static void
initialize (text_fuzzy_t * tf)
{
    tf->distance = -1;
    tf->ualphabet.rejections = 0;
    tf->length_rejections = 0;

    /* If the maximum distance is set to a value larger than the
       number of characters in the string, set the maximum distance to
       the number of characters in the string, regardless of what the
       user might have requested. */

    if (tf->unicode) {
	if (tf->max_distance > tf->text.ulength) {
	    tf->max_distance = tf->text.ulength;
	}
    }
    else {
	if (tf->max_distance > tf->text.length) {
	    tf->max_distance = tf->text.length;
	}
    }
}

typedef struct candidate candidate_t;

struct candidate {
    int distance;
    int offset;
    candidate_t * next;
};

static int
text_fuzzy_av_distance (text_fuzzy_t * text_fuzzy, AV * words, AV * wantarray)
{
    int i;
    int n_words;
    int max_distance_holder;
    int nearest;
    candidate_t first;
    candidate_t * last;

    max_distance_holder = text_fuzzy->max_distance;

    if (wantarray) {
	last = & first;
    }

    nearest = -1;

    initialize (text_fuzzy);

    n_words = av_len (words) + 1;
    if (n_words == 0) {
        return -1;
    }
    for (i = 0; i < n_words; i++) {
        SV * word;
        word = * av_fetch (words, i, 0);
        sv_to_text_fuzzy_string (word, text_fuzzy);
        TEXT_FUZZY (compare_single (text_fuzzy));
        if (text_fuzzy->found) {
            text_fuzzy->max_distance = text_fuzzy->distance;
            nearest = i;
	    if (wantarray) {
		candidate_t * c;
		get_memory (c, 1, candidate_t);
		c->distance = text_fuzzy->distance;
		c->offset = i;
		c->next = 0;
		last->next = c;
		last = c;
	    }
	    else {
		if (text_fuzzy->distance == 0) {
		    /* Stop the search if there is an exact match. */
		    break;
		}
	    }
	}
    }
    text_fuzzy->distance = text_fuzzy->max_distance;

    /* Set the maximum distance back to the user's value. */

    text_fuzzy->max_distance = max_distance_holder;

    /* Go through the linked list and sort the wheat from the chaf. */

    if (wantarray) {
	candidate_t * c;
	last = first.next;
	while (last) {
	    c = last;
	    /* Set "last" to the next one here so that we do not
	       access freed memory. */
	    last = last->next;
	    if (c->distance == text_fuzzy->distance) {
		SV * offset;

		offset = newSViv (c->offset);
		av_push (wantarray, offset);
	    }
	    Safefree (c);
	    text_fuzzy->n_mallocs--;
	}
    }
    return nearest;
}


/* Free the memory allocated to "text_fuzzy" and check that there has
   not been a memory leak. */

static int text_fuzzy_free (text_fuzzy_t * text_fuzzy)
{
    if (text_fuzzy->b.unicode) {
	Safefree (text_fuzzy->b.unicode);
	text_fuzzy->n_mallocs--;
    }

    /* See the comments in "text-fuzzy.c.in" about why this is
       necessary. */

    TEXT_FUZZY (free_memory (text_fuzzy));

    if (text_fuzzy->unicode) {
        Safefree (text_fuzzy->text.unicode);
        text_fuzzy->n_mallocs--;
    }

    Safefree (text_fuzzy->text.text);
    text_fuzzy->n_mallocs--;

    if (text_fuzzy->n_mallocs != 1) {
        warn ("memory leak: n_mallocs %d != 1", text_fuzzy->n_mallocs);
    }
    Safefree (text_fuzzy);

    return 0;
}

