#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define FAIL_STATUS
#define ERROR_HANDLER perl_error_handler

#include "text-fuzzy.h"
#include "text-fuzzy-perl.c"

#undef FAIL_STATUS
#define FAIL_STATUS

typedef text_fuzzy_t * Text__Fuzzy;

MODULE=Text::Fuzzy PACKAGE=Text::Fuzzy

PROTOTYPES: ENABLE

Text::Fuzzy
new (class, search_term, max_distance = 10)
	const char * class;
	SV * search_term;
	int max_distance;
CODE:
	/* Set the error handler in "text-fuzzy.c" to be the error
	   handler defined in "text-fuzzy-perl.c". */
	text_fuzzy_error_handler = perl_error_handler;

	sv_to_text_fuzzy (search_term, max_distance, & RETVAL);

        if (! RETVAL) {
        	croak ("error making %s.\n", class);
	}
OUTPUT:
        RETVAL

SV *
get_max_distance (tf)
	Text::Fuzzy tf;
CODE:
        if (tf->max_distance >= 0) {
		RETVAL = newSViv (tf->max_distance);
	}
	else {
		RETVAL = &PL_sv_undef;
	}
OUTPUT:
	RETVAL

void
set_max_distance (tf, max_distance = &PL_sv_undef)
	Text::Fuzzy tf;
	SV * max_distance;
CODE:
        if (SvOK (max_distance)) {
		tf->max_distance = (int) SvIV (max_distance);
	}
	else {
        	tf->max_distance = NO_MAX_DISTANCE;
	}


void
transpositions_ok (tf, trans)
	Text::Fuzzy tf;
	SV * trans;
CODE:
	if (SvTRUE (trans)) {
		tf->transpositions_ok = 1;
	}
	else {
		tf->transpositions_ok = 0;
	}

int
get_trans (tf)
	Text::Fuzzy tf;
CODE:
	RETVAL = tf->transpositions_ok;
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

void
nearest (tf, words)
	Text::Fuzzy tf;
        AV * words;
PPCODE:
	int i;
	int n;
	AV * wantarray;

	wantarray = 0;

	if (GIMME_V == G_ARRAY) {
		wantarray = newAV ();
		n = text_fuzzy_av_distance (tf, words, wantarray);
	}
	else {
		n = text_fuzzy_av_distance (tf, words, 0);
	}
	/* We could check for void context and return here I suppose ... */
	if (wantarray) {
		EXTEND (SP, av_len (wantarray));
		for (i = 0; i <= av_len (wantarray); i++) {
			PUSHs (sv_2mortal (*(av_fetch (wantarray, i, 0))));
		}
        }
        else {
            PUSHs (sv_2mortal (newSViv (n)));
        }

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
no_alphabet (tf, yes_no)
	Text::Fuzzy tf;
        SV * yes_no;
CODE:
	tf->user_no_alphabet = SvTRUE (yes_no);
	if (tf->user_no_alphabet) {
		tf->use_alphabet = 0;
		tf->use_ualphabet = 0;
	}

int
ualphabet_rejections (tf)
	Text::Fuzzy tf;
CODE:
	RETVAL = tf->ualphabet.rejections;
OUTPUT:
        RETVAL


int
length_rejections (tf)
	Text::Fuzzy tf;
CODE:
	RETVAL = tf->length_rejections;
OUTPUT:
        RETVAL


void
DESTROY (tf)
	Text::Fuzzy tf;
CODE:
	text_fuzzy_free (tf);

char *
scan_file (tf, file_name)
	Text::Fuzzy tf;
        char * file_name;
CODE:
        TEXT_FUZZY (scan_file (tf, file_name, & RETVAL));
OUTPUT:
        RETVAL

void
no_exact (tf, yes_no)
	Text::Fuzzy tf;
	SV * yes_no;
CODE:
	tf->no_exact = SvTRUE (yes_no);
