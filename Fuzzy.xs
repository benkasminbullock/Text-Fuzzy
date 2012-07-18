#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define FAIL_STATUS
#define ERROR_HANDLER perl_error_handler

#include "text-fuzzy.h"
#include "text-fuzzy-perl.c"

typedef text_fuzzy_t * Text__Fuzzy;

MODULE=Text::Fuzzy PACKAGE=Text::Fuzzy

PROTOTYPES: ENABLE

Text::Fuzzy
new (class, search_term, max_distance = 10)
	const char * class;
	SV * search_term;
	int max_distance;
CODE:
	sv_to_text_fuzzy (search_term, max_distance, & RETVAL);
        if (! RETVAL) {
        	printf ("error making %s.\n", class);
	}
OUTPUT:
        RETVAL

int
max_distance (tf, max_distance = -1)
	Text::Fuzzy tf;
        int max_distance;
CODE:
        if (max_distance >= 0) {
        	tf->max_distance = max_distance;
	}
	RETVAL = tf->max_distance;
OUTPUT:
	RETVAL

int
distance (tf, word)
	Text::Fuzzy tf;
        SV * word;
CODE:
	RETVAL = text_fuzzy_sv_distance (tf, word);
OUTPUT:
	RETVAL

int
nearest (tf, words)
	Text::Fuzzy tf;
        AV * words;
CODE:
        int distance = -1;
	RETVAL = text_fuzzy_av_distance (tf, words, & distance);
        tf->distance = distance;
OUTPUT:
	RETVAL

int
last_distance (tf)
	Text::Fuzzy tf;
CODE:
	RETVAL = tf->distance;
OUTPUT:
	RETVAL

SV *
unicode_length (tf)
	Text::Fuzzy tf;
CODE:
        if (tf->text.unicode) {
		RETVAL = newSViv (tf->text.ulength);
	}
	else {
		RETVAL = &PL_sv_undef;
	}
OUTPUT:
	RETVAL

void
DESTROY (tf)
	Text::Fuzzy tf;
CODE:
	text_fuzzy_free (tf);