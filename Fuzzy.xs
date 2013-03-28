#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#define FAIL_STATUS
#define ERROR_HANDLER perl_error_handler

#include "config.h"
#include "text-fuzzy.h"
#include "text-fuzzy-perl.c"

#undef FAIL_STATUS
#define FAIL_STATUS

typedef text_fuzzy_t * Text__Fuzzy;

MODULE=Text::Fuzzy PACKAGE=Text::Fuzzy

PROTOTYPES: ENABLE

BOOT:
	/* Set the error handler in "text-fuzzy.c" to be the error
	   handler defined in "text-fuzzy-perl.c". */

	text_fuzzy_error_handler = perl_error_handler;


Text::Fuzzy
new (class, search_term, ...)
	const char * class;
	SV * search_term;
CODE:
	int i;
	text_fuzzy_t * r;

	r = 0;

	sv_to_text_fuzzy (search_term, & r);

        if (! r) {
        	croak ("error making %s.\n", class);
	}

	/* Loop over the parameters in "...". The first two terms are
	   "class" and "search_term", so we start from 2 here. */

	for (i = 2; i < items; i++) {
		SV * x;
		char * p;
		unsigned int len;

		if (i >= items - 1) {
			warn ("Odd number of parameters %d of %d",
			      i, (int) items);
			break;
		}

		/* Read in parameters in the "form max => 22",
		"no_exact => 1", etc. */

		x = ST (i);
		p = (char *) SvPV (x, len);
		if (strncmp (p, "max", strlen ("max")) == 0) {
			r->max_distance = SvIV (ST (i + 1));
			if (r->max_distance < 0) {
				r->max_distance = NO_MAX_DISTANCE;
			}
		}
		else if (strncmp (p, "no_exact", strlen ("no_exact")) == 0) {
			r->no_exact = SvTRUE (ST (i + 1)) ? 1 : 0;
		}
		else if (strncmp (p, "trans", strlen ("trans")) == 0) {
			r->transpositions_ok = SvTRUE (ST (i + 1)) ? 1 : 0;
		}
		else {
			warn ("Unknown parameter %s", p);
		}
		/* Plan to throw one away; you will anyway. */
		i++;
	}
	RETVAL = r;
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
PREINIT:
	int i;
	int n;
	AV * wantarray;
PPCODE:

	wantarray = 0;

	if (GIMME_V == G_ARRAY) {

	   	/* The user wants an array containing all of the
	   	nearest values. */

		wantarray = newAV ();
		/* Free the array */
		sv_2mortal ((SV *) wantarray);
		n = text_fuzzy_av_distance (tf, words, wantarray);
	}
	else {
		/* Even in void context, we still do the search, in
		   case the user just wants to know the minimum
		   distance and ignores the actual values. */

		n = text_fuzzy_av_distance (tf, words, 0);
	}

	if (wantarray) {
		SV * e;
		EXTEND (SP, av_len (wantarray));
		for (i = 0; i <= av_len (wantarray); i++) {
			e = * av_fetch (wantarray, i, 0);
			SvREFCNT_inc_simple_void_NN (e);
			PUSHs (sv_2mortal (e));
		}
        }
        else {
		if (n >= 0) {
            		PUSHs (sv_2mortal (newSViv (n)));
		}
		else {
            		PUSHs (& PL_sv_undef);
		}
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

int
alphabet_rejections (tf)
	Text::Fuzzy tf;
CODE:
	TEXT_FUZZY (alphabet_rejections (tf, & RETVAL));
OUTPUT:
	RETVAL

void
DESTROY (tf)
	Text::Fuzzy tf;
CODE:
	text_fuzzy_free (tf);

