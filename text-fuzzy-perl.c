#define NO_MAX_DISTANCE -1

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

static int * sv_to_int_ptr (SV * text, int * ulength_ptr)
{
    int i;
    int ulength;
    int * unicode;
    U8 * utf;
    STRLEN curlen;
    STRLEN length;
    unsigned char * stuff;

    stuff = (unsigned char *) SvPV (text, length);

    ulength = sv_len_utf8 (text);
    Newxz (unicode, ulength, int);
    if (! unicode) {
        croak ("%s:%d: %s", __FILE__, __LINE__, "Error allocating");
    }
    utf = stuff;
    curlen = length;
    for (i = 0; i < ulength; i++) {
        STRLEN len;
        unicode[i] = utf8n_to_uvuni (utf, curlen, & len, 0);
        curlen -= len;
        utf += len;
    }
    * ulength_ptr = ulength;
    return unicode;
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

    get_memory (text_fuzzy, 1, text_fuzzy_t);
    text_fuzzy->max_distance = max_distance;
    stuff = (unsigned char *) SvPV (text, length);
    text_fuzzy->text.length = length;
    get_memory (text_fuzzy->text.text, length + 1, char);
    for (i = 0; i < length; i++) {
        text_fuzzy->text.text[i] = stuff[i];
    }
    text_fuzzy->text.text[text_fuzzy->text.length] = '\0';
    is_utf8 = SvUTF8 (text);
    if (is_utf8) {
        text_fuzzy->unicode = 1;
        text_fuzzy->text.unicode =
            sv_to_int_ptr (text,
                           & text_fuzzy->text.ulength);
        text_fuzzy->n_mallocs++;
	TEXT_FUZZY (generate_ualphabet (text_fuzzy));
	//text_fuzzy->ualphabet.valid = 0;
    }
    else {
        TEXT_FUZZY (generate_alphabet (text_fuzzy));
    }
    * text_fuzzy_ptr = text_fuzzy;
}

static void text_fuzzy_free (text_fuzzy_t * text_fuzzy)
{
    if (text_fuzzy->ualphabet.valid) {
	free (text_fuzzy->ualphabet.alphabet);
	text_fuzzy->n_mallocs--;
    }

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
}

#undef FAIL_STATUS
#define FAIL_STATUS -1

static void
sv_to_text_fuzzy_string (SV * word, text_fuzzy_string_t * b,
                         int force_unicode)
{
    STRLEN length;
    b->text = SvPV (word, length);
    b->length = length;
    if (SvUTF8 (word) || force_unicode) {
        b->unicode = sv_to_int_ptr (word, & b->ulength);
    }
}

static int
text_fuzzy_sv_distance (text_fuzzy_t * tf, SV * word)
{
    text_fuzzy_string_t b = {0};
    sv_to_text_fuzzy_string (word, & b, tf->unicode);
    TEXT_FUZZY (compare_single (tf, & b));
    if (b.unicode) {
        Safefree (b.unicode);
    }
    if (tf->found) {
        return tf->distance;
    }
    else {
        return tf->max_distance + 1;
    }
}

static int
text_fuzzy_av_distance (text_fuzzy_t * tf, AV * words, int * distance_ptr)
{
    int i;
    int n_words;
    int max_distance_holder;
    int nearest;

    max_distance_holder = tf->max_distance;
    nearest = -1;

    /* If the maximum distance is set to a value larger than the
       number of characters in the string, set the maximum distance to
       the number of characters in the string, regardless of what the
       user might have requested. */

    if (tf->unicode) {
	if (tf->max_distance > tf->text.ulength) {
#ifdef DEBUG
	    fprintf (stderr, "Reducing max distance from %d to %d\n", tf->max_distance, tf->text.ulength);
#endif
	    tf->max_distance = tf->text.ulength;
	}
#ifdef DEBUG
	else {
	    fprintf (stderr, "boo to a goose\n");
	}
#endif
    }
    else {
	if (tf->max_distance > tf->text.length) {
	    tf->max_distance = tf->text.length;
	}
    }

    n_words = av_len (words) + 1;
    if (n_words == 0) {
        return -1;
    }
    for (i = 0; i < n_words; i++) {
        SV * word;
        text_fuzzy_string_t b;
        word = * av_fetch (words, i, 0);
        sv_to_text_fuzzy_string (word, & b, tf->unicode);
        TEXT_FUZZY (compare_single (tf, & b));
        if (tf->found) {
            tf->max_distance = tf->distance;
            nearest = i;
            if (tf->distance == 0) {
                /* Stop the search if there is an exact match. */
                break;
            }
        }
    }
    * distance_ptr = tf->max_distance;
    /* Set the maximum distance back to the user's value. */
    tf->max_distance = max_distance_holder;
#ifdef DEBUG
    fprintf (stderr, "Rejected using alphabet: %d\n", tf->ualphabet.rejected);
#endif
    return nearest;
}

