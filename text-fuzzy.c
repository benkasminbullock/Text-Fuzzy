#include <string.h>
#include <errno.h>
#include <limits.h>
#include "text-fuzzy.h"
#include "edit-distance-char-trans.h"
#include "edit-distance-int-trans.h"
#include "edit-distance-char.h"
#include "edit-distance-int.h"

#ifndef ERROR_HANDLER
#define ERROR_HANDLER text_fuzzy_error_handler;
#endif /* undef ERROR_HANDLER */
#include "text-fuzzy.h"
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

#ifndef ERROR_HANDLER_H
#define ERROR_HANDLER_H
typedef int (* error_handler_t) (const char * source_file,
                                 int source_line_number,
                                 const char * message, ...)
#ifdef __GNUC__
    __attribute__((format (printf, 3, 4)))
#endif /* __GNUC__ */
;
#endif /* ndef ERROR_HANDLER_H */

extern error_handler_t text_fuzzy_error_handler;


/* This is the default error handler for this namespace. */

static int
text_fuzzy_default_error_handler (const char * source_file,
                                        int source_line_number,
                                        const char * message, ...)
{
    va_list args;

    fprintf (stderr, "%s:%d: ", source_file, source_line_number);
    va_start (args, message);
    vfprintf (stderr, message, args);
    exit (EXIT_FAILURE);
}

/* This global variable is the error handler for this namespace. */

error_handler_t text_fuzzy_error_handler =
    text_fuzzy_default_error_handler;


/* Print an error message for a failed condition "condition" at the
   appropriate line. */

#define LINE_ERROR(condition, status)                                   \
    if (text_fuzzy_error_handler) {                               \
        (* text_fuzzy_error_handler)                              \
            (__FILE__, __LINE__,                                        \
             "Failed test '%s', returning status '%s': %s",             \
             #condition, #status,                                       \
             text_fuzzy_statuses                                  \
             [text_fuzzy_status_ ## status]);                     \
    }                                                               

/* Fail a test, without message. */

#define FAIL(condition, status)                                         \
    if (condition) {                                                    \
        LINE_ERROR (condition, status);                                 \
        return text_fuzzy_status_ ## status;                      \
    }

/* Fail a test, with message. */

#define FAIL_MSG(condition, status, msg, args...)                       \
    if (condition) {                                                    \
        LINE_ERROR (condition, status);                                 \
        if (text_fuzzy_error_handler) {                           \
            (* text_fuzzy_error_handler)                          \
                (__FILE__, __LINE__,                                    \
                 msg, ## args);                                         \
        }                                                               \
        return text_fuzzy_status_ ## status;                      \
    }

#define OK return text_fuzzy_status_ok;

/* Call a function and print an error message and return if the
   function returns an error value. */

#define CALL(x) {                                                       \
	text_fuzzy_status_t _status = text_fuzzy_ ## x;     \
	if (_status != text_fuzzy_status_ok) {                    \
            if (text_fuzzy_error_handler) {                       \
                (* text_fuzzy_error_handler)                      \
                    (__FILE__, __LINE__,                                \
                     "Call 'text_fuzzy_%s' "                      \
                     "failed with status '%d': %s",                     \
                     #x, _status,                                       \
                     text_fuzzy_statuses[_status]);       \
            }                                                           \
            return _status;                                             \
        }                                                               \
    }

/*
Local variables:
mode: c
End:
*/

const char * text_fuzzy_statuses[] = {
    "normal operation",
    "out of memory",
    "open error",
    "close error",
    "read error",
    "line too long",
    "There was an attempt to make a Unicode alphabet on a non-Unicode string.",
    "max min miscalculation",
    "A string for comparison was larger than the value of HUGE defined in the code.",
};

#define STATIC static
#define FUNC(name) text_fuzzy_status_t text_fuzzy_ ## name

#ifdef VERBOSE
#define MESSAGE(format, args...) {              \
        printf ("%s:%d: ", __FILE__, __LINE__); \
        printf (format, ## args);               \
}
#else /* VERBOSE */
#define MESSAGE(format, args...)
#endif /* VERBOSE */

/* Local variables:
mode: c
End:
*/

#line 1 "/usr/home/ben/projects/Text-Fuzzy/text-fuzzy.c.in"

/* For error-handling for the file opening functions. */

/* For INT_MAX, INT_MIN. */




/* All of the following are automatically generated from
   "edit-distance.h.tmpl" by "make-edit-distance-c.pl". */






/* The following starts off the header file. This is a tag which tells
   "C::Maker" to start writing "text-fuzzy.h". */

#ifdef HEADER

/* Alphabet over unicode characters. */

typedef struct ualphabet {

    /* The smallest character in our alphabet. */
    int min;

    /* The largest character in our alphabet. */
    int max;

    /* Number of chars allocated in the following array. */
    int size;

    /* Array containing Unicode alphabet, as a bitmap. */
    unsigned char * alphabet;

    /* The number of characters which were rejected using the Unicode
       alphabet. */
    int rejections;
}
ualphabet_t;

/* This structure contains one string of whatever type. */

typedef struct text_fuzzy_string {

    /* The text of the string. */
    char * text;

    /* The length of "text". */
    int length;

    /* The characters of "text" expanded out into unicode
       characters. */
    int * unicode;

    /* The length of "unicode". */
    int ulength;
}
text_fuzzy_string_t;

/* The following structure contains one string plus additional
   paraphenalia used in searching for the string, for example the
   alphabet of the string. */

typedef struct text_fuzzy {

    /* The string we are to match. */
    text_fuzzy_string_t text;

    /* The matching string. */

    text_fuzzy_string_t b;

    /* The maximum edit distance we allow for. */
    int max_distance;

    /* The number of mallocs we are guilty of. */
    int n_mallocs;

    /* ASCII alphabet */
    int alphabet[0x100];

    /* Unicode alphabet. */
    ualphabet_t ualphabet;

    /* The minimum distance we got in our most recent effort. */
    int distance;

    /* The number of units allocated for "b.unicode". This is not the
       string length. This is used when deciding whether there is
       sufficient space to store a test string. */
    int b_unicode_length;

    /* The number of items which have been rejected because the length
       difference is bigger than the maximum edit distance. */
    int length_rejections;

    /* Does the user want to use an alphabet filter? Default is yes,
       so this must be set to a non-zero value to switch off use. */
    int user_no_alphabet : 1;

    /* Are we actually going to use it? (This may be false even if the
       user wants to use it, for silly cases, but is not true if the
       user does not want to use it.) */
    int use_alphabet : 1;
    int use_ualphabet : 1;

    /* Variable edit costs? (currently unused) */
    int variable_edit_costs : 1;

    /* Do we account for transpositions? */
    int transpositions_ok : 1;

    /* Did we find it? */
    int found : 1;

    /* Is this Unicode? */
    int unicode : 1;
}
text_fuzzy_t;

#endif /* HEADER */

/* The maximum feasible size of the Unicode alphabet. */

#define UALPHABET_MAX_SIZE 0x10000

/* The following calculations need to be done twice, first when
   creating the alphabet and second when looking up a new character in
   it. The macro saves us from exasperating bugs. */

#define BYTE_BIT				\
    byte = ((c - u->min) / 8) ;			\
    bit = 1 << (c % 8);

/* Generate the Unicode alphabet in "tf->ualphabet". */

FUNC (generate_ualphabet) (text_fuzzy_t * tf)
{
    int i;

    /* "u" is a pointer to the alphabet in "tf". This saves repeatedly
       typing "tf->ualphabet". */

    ualphabet_t * u;

    /* "t" is a pointer to the string in "tf". This saves repeatedly
       typing "tf->text". */

    text_fuzzy_string_t * t;

    /* Check this routine was not called by mistake. */

    FAIL (! tf->unicode, ualphabet_on_non_unicode);

    u = & tf->ualphabet;
    t = & tf->text;

    MESSAGE ("Alphabetizing %s\n", t->text);

    /* Set the maximum to the smallest possible value and the minimum
       to the largest possible value. */

    u->min = INT_MAX;
    u->max = INT_MIN;

    /* Get the minimum and maximum values. */

    for (i = 0; i < t->ulength; i++) {

	/* Character at position "i". */

	int c;

	c = t->unicode[i];

	if (c > u->max) {
	    u->max = c;
	}
	if (c < u->min) {
	    u->min = c;
	}
    }

    MESSAGE ("Range is %X - %X\n", u->min, u->max);

    /* The number of bytes we need to store the alphabet. */

    u->size = u->max /8 - u->min / 8 + 1;

    if (u->size >= UALPHABET_MAX_SIZE) {

	/* Give up trying to make this alphabet. */

	OK;
    }

    /* Create a zeroed alphabet. */

    u->alphabet = calloc (u->size, sizeof (char));
    FAIL (! u->alphabet, memory_error);

    tf->n_mallocs++;

    /* Get the minimum and maximum values. */

    for (i = 0; i < t->ulength; i++) {

	/* Character at position "i". */



	int c;

	/* Byte and bit offset of c in u->alphabet. */

	int byte;
	unsigned char bit;

	c = t->unicode[i];
	FAIL (c > u->max || c < u->min, max_min_miscalculation);

	BYTE_BIT;
	MESSAGE ("Accepting %X at byte %X, bit %X.\n", c, byte, bit);
	FAIL_MSG (byte < 0 || byte >= u->size, max_min_miscalculation,
		  "The value of byte is %d, not within 0 - %d", byte, u->size);

	u->alphabet[byte] |= bit;
    }

    /* We have succeeded. */

    tf->use_ualphabet = 1;

    MESSAGE ("Size %d, min %d, max %d\n", u->size, u->min, u->max);

    OK;
}

/* This returns a true value if the difference between the alphabet of
   "b" and the alphabet of "tf" is greater than the maximum distance
   which "tf" will accept. */

static int ualphabet_miss (text_fuzzy_t * tf, text_fuzzy_string_t * b)
{
    int i;

    /* "u" is a pointer to the alphabet in "tf". This saves repeatedly
       typing "tf->ualphabet". */

    ualphabet_t * u;

    /* The number of misses. */

    int misses;

    u = & tf->ualphabet;

    misses = 0;

    for (i = 0; i < tf->b.ulength; i++) {

	int c;

	c = tf->b.unicode[i];
	MESSAGE ("Looking for %X: ", c);

	/* Eliminate too large or too small. */

	if (c >= u->min && c <= u->max) {

	    /* Byte and bit offset of c in u->alphabet. */

	    int byte;
	    unsigned char bit;

	    BYTE_BIT;

	    MESSAGE (" byte %X, bit %X: ", byte, bit);

	    /* Exact check against the alphabet of "tf". */

	    if (! (u->alphabet[byte] & bit)) {
		MESSAGE ("not ");
		misses++;
	    }
	    MESSAGE ("there.\n");
	}
	else {
	    misses++;
	    MESSAGE (" out of bounds.\n");
	}

	/* If we have too many misses, stop searching. */

	if (misses >= tf->max_distance) {
	    MESSAGE ("%s:%s: %d misses over %d: ",
		    tf->text.text, tf->b.text, misses, tf->max_distance);
	    return 1;
	}
    }
    return 0;
}

/* This is a value for the edit distance which indicates complete
   failure to match. */

#define NOT_FOUND -1

#define LENGTH_REJECT(x,y)						\
    MESSAGE ("Length of %d can never match %d within %d edits",		\
	     (x), (y), tf->max_distance);				\
    tf->length_rejections++


/* Compare tf and b. This goes through a series of filters which
   reject impossible matches, and then if none of the filters applies,
   it uses the dynamic programming algorithm to search. The source
   code for the dynamic programming algorithms is in
   "edit-distance.c.tmpl". */

FUNC (compare_single) (text_fuzzy_t * tf)
{

    /* The edit distance between "tf->search_term" and the
       truncated version of "tf->buf". */

    int d;

    d = NOT_FOUND;

    tf->found = 0;

    if (tf->unicode) {

	if (tf->max_distance >= 0) {

	    /* Filter on distance: If the distance in the length of
	       the strings is greater than the max distance, give up,
	       since the number of additions necessary to make the
	       strings identical is greater than the maximum distance
	       we are allowed. */

	    if (abs (tf->text.ulength - tf->b.ulength) > tf->max_distance) {

		LENGTH_REJECT (tf->b.ulength, tf->text.ulength);

		OK;
	    }
	    if (tf->use_ualphabet) {

		/*
		  Check that the length of "b" is more than the maximum
		  distance, otherwise the alphabet check will not reject
		  "b" regardless of the alphabet difference found, since
		  the largest possible value of "misses" in the alphabet
		  check is the total number of characters in "b".
		*/

		if (tf->b.ulength > tf->max_distance) {

		    /* Filter using alphabet: If the number of
		       characters in "b" which are not in "tf->text"
		       is greater than the maximum distance, give
		       up. */

		    if (ualphabet_miss (tf, & tf->b)) {

			MESSAGE ("Rejected.\n");

			tf->ualphabet.rejections++;

			OK;
		    }
		    else {
			MESSAGE ("Accepted.\n");
		    }
		}
		else {
		    MESSAGE ("%s: skipping alphabet check because len %d <= max %d.\n",
			     tf->b.text, tf->b.ulength, tf->max_distance);
		}
	    }
	}

	/* Calculate edit distances using the dynamic programming
	   algorithm for the integer Unicode strings. */

	if (tf->transpositions_ok) {
	    MESSAGE ("Transpositions OK.\n");
	    d = distance_int_trans (tf->b.unicode, tf->b.ulength, tf);
	}
	else {
	    MESSAGE ("No transpositions.\n");
	    d = distance_int (tf->b.unicode, tf->b.ulength, tf);
	}
    }
    else {

	/* This is not Unicode. */

        if (tf->max_distance >= 0) {

            /* If the distance in the length of the strings is greater
               than the max distance, give up. */

            if (abs (tf->text.length - tf->b.length) > tf->max_distance) {

		LENGTH_REJECT (tf->b.length, tf->text.length);
	    
                OK;
            }

	    /* See comment in the Unicode version, above. */

	    if (tf->b.length > tf->max_distance) {

		/* Alphabet filter: eliminate terms which cannot match. */

		if (tf->use_alphabet) {
		    int alphabet_misses;
		    int l;

		    alphabet_misses = 0;

		    for (l = 0; l < tf->b.length; l++) {

			int a = (unsigned char) tf->b.text[l];

			if (! tf->alphabet[a]) {
			    alphabet_misses++;
			    if (alphabet_misses > tf->max_distance) {

				/* It is not possible that the two words
				   are within the maximum edit distance of
				   each other. */

				OK;
			    }
			}
		    }
		}
	    }
        }
        /* Calculate the edit distance using the dynamic programming
	   algorithm for "unsigned char". */

	if (tf->transpositions_ok) {
	    d = distance_char_trans (tf->b.text, tf->b.length, tf);
	}
	else {
	    d = distance_char (tf->b.text, tf->b.length, tf);
	}
    }
    if (d != NOT_FOUND && d <= tf->max_distance) {
        tf->found = 1;
        tf->distance = d;
    }
    OK;
}

/* This is the threshold above which we do not bother computing the
   alphabet of the string. If it has more than this number of unique
   characters, the alphabet will not reduce the search time by
   much. */

static int max_unique_characters = 45;

/* Generate an alphabet from the search word, which is used to filter
   non-matching terms without using the dynamic programming
   algorithm. */

FUNC (generate_alphabet) (text_fuzzy_t * text_fuzzy)
{
    int unique_characters;
    int i;

    text_fuzzy->use_alphabet = 1;

    for (i = 0; i < 0x100; i++) {
        text_fuzzy->alphabet[i] = 0;
    }
    unique_characters = 0;
    for (i = 0; i < text_fuzzy->text.length; i++) {
        int c;
        c = (unsigned char) text_fuzzy->text.text[i];
        if (! text_fuzzy->alphabet[c]) {
            unique_characters++;
            text_fuzzy->alphabet[c] = 1;
        }
    }
    if (unique_characters > max_unique_characters) {
        text_fuzzy->use_alphabet = 0;
    }
    OK;
}

/*   __ _ _         __                  _   _                 
    / _(_) | ___   / _|_   _ _ __   ___| |_(_) ___  _ __  ___ 
   | |_| | |/ _ \ | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
   |  _| | |  __/ |  _| |_| | | | | (__| |_| | (_) | | | \__ \
   |_| |_|_|\___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/ */
                                                           


#define BUF_SIZE 0x1000

typedef struct fuzzy_file {
    const char * file_name;
    FILE * fh;
    char buf[BUF_SIZE];
    char * line;
    int length;
    text_fuzzy_string_t b;
    int remaining;
    int offset;
    int eof : 1;
}
fuzzy_file_t;

#define SIZE 0x1000

STATIC FUNC (more_bytes) (fuzzy_file_t * ff)
{
    int bytes;

    bytes = fread (ff->buf, sizeof (char), SIZE, ff->fh);
    if (bytes != SIZE) {
        if (feof (ff->fh)) {
            ff->eof = 1;
        }
        else {
            FAIL (bytes != SIZE, read_error);
        }
    }
    ff->remaining = bytes;
    ff->offset = 0;
    OK;
}

STATIC FUNC (get_line) (fuzzy_file_t * ff)
{
    int i;
    static char s[SIZE];

    i = 0;
    while (1) {
        char c;
        if (! ff->remaining) {
            CALL (more_bytes (ff));
        }
        c = ff->buf[ff->offset];
        ff->offset++;
        ff->remaining--;
        if (c == '\n' || (ff->remaining == 0 && ff->eof)) {
            s[i] = '\0';
            break;
        }
        else {
            s[i] = c;
        }
        i++;
        FAIL (i >= SIZE, line_too_long);
    }

    ff->b.text = s;
    ff->b.length = i;

    OK;
}

STATIC FUNC (open) (fuzzy_file_t * ff, const char * file_name)
{
    ff->file_name = file_name;
    ff->fh = fopen (ff->file_name, "r");
    FAIL_MSG (! ff->fh, open_error, "failed to open %s: %s", ff->file_name,
              strerror (errno));
    OK;
}

STATIC FUNC (close) (fuzzy_file_t * ff)
{
    FAIL (fclose (ff->fh), close_error);
    OK;
}

/* Scan the file specified by "file_name" for our string. The nearest
   string found is returned in "* nearest_ptr". */

FUNC (scan_file) (text_fuzzy_t * text_fuzzy, char * file_name,
                  char ** nearest_ptr)
{
    fuzzy_file_t ff = {0};
    char * nearest;
    int found;
    int max_distance_holder;

    CALL (open (& ff, file_name));

    max_distance_holder = text_fuzzy->max_distance;
    
    found = 0;
    nearest = 0;
    while (1) {
        CALL (get_line (& ff));
	text_fuzzy->b = ff.b;
        CALL (compare_single (text_fuzzy));
        if (text_fuzzy->found) {
            found = 1;
            if (text_fuzzy->distance < text_fuzzy->max_distance) {
                text_fuzzy->max_distance = text_fuzzy->distance;
                if (! nearest) {
                    nearest = malloc (ff.b.length + 1);
                }
                else {
                    nearest = realloc (nearest, ff.b.length + 1);
                }
                FAIL (! nearest, memory_error);
                strncpy (nearest, ff.b.text, ff.b.length);
                nearest[ff.b.length] = '\0';
            }
        }
        if (ff.eof && ff.remaining == 0) {
            break;
        }
    }

    CALL (close (& ff));

    text_fuzzy->max_distance = max_distance_holder;
    if (found) {
        * nearest_ptr = nearest;
    }
    else {
        * nearest_ptr = 0;
    }
    OK;
}

/* statuses:

status: open_error

status: close_error

status: read_error

status: line_too_long

status: ualphabet_on_non_unicode
%%description:
There was an attempt to make a Unicode alphabet on a non-Unicode string.
%%

status: max_min_miscalculation

status: string_too_long
%%description:
A string for comparison was larger than the value of HUGE defined in the code.
%%

*/

