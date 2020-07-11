#!/bin/bash
DATA=/nmt/work/EX-MS/data/UN6WAY_Nolack_Multi

cat $1 \
    | sed 's/\@\@ //g' \
    | ../tools/moses-scripts/scripts/recaser/detruecase.perl 2>/dev/null \
    | ../tools/moses-scripts/scripts/tokenizer/detokenizer.perl -l de 2>/dev/null \
    | ../tools/moses-scripts/scripts/generic/multi-bleu-detok.perl $DATA/valid.en \
    | sed -r 's/BLEU = ([0-9.]+),.*/\1/'
