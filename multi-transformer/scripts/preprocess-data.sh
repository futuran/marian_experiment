#!/bin/bash -v

# suffix of source language files
SRC1=de
SRC2=fr

# suffix of target language files
TRG=en

# number of merge operations
bpe_operations=32000

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=../tools/moses-scripts

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
subword_nmt=../tools/subword-nmt

# tokenize
for prefix in corpus
do
    cat multi_data/$prefix.$SRC1 \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $SRC1 \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC1 > multi_data/$prefix.tok.$SRC1

    cat multi_data/$prefix.$SRC2 \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $SRC2 \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC2 > multi_data/$prefix.tok.$SRC2

    test -f multi_data/$prefix.$TRG || continue

    cat multi_data/$prefix.$TRG \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $TRG \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > multi_data/$prefix.tok.$TRG
done

echo "fin 1"

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
mv multi_data/corpus.tok.$SRC1 multi_data/corpus.tok.uncleaned.$SRC1
mv multi_data/corpus.tok.$SRC2 multi_data/corpus.tok.uncleaned.$SRC2
mv multi_data/corpus.tok.$TRG multi_data/corpus.tok.uncleaned.$TRG
$mosesdecoder/scripts/training/clean-corpus-n.perl multi_data/corpus.tok.uncleaned $SRC1 $TRG  multi_data/corpus.tok 1 100
$mosesdecoder/scripts/training/clean-corpus-n.perl multi_data/corpus.tok.uncleaned $SRC2 $TRG  multi_data/corpus.tok 1 100

echo "fin 2"

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus multi_data/corpus.tok.$SRC1 -model model/tc.$SRC1
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus multi_data/corpus.tok.$SRC2 -model model/tc.$SRC2
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus multi_data/corpus.tok.$TRG -model model/tc.$TRG

echo "fin 3"

# apply truecaser (cleaned training corpus)
for prefix in corpus
do
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$SRC1 < multi_data/$prefix.tok.$SRC1 > multi_data/$prefix.tc.$SRC1
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$SRC2 < multi_data/$prefix.tok.$SRC2 > multi_data/$prefix.tc.$SRC2
    test -f multi_data/$prefix.tok.$TRG || continue
    $mosesdecoder/scripts/recaser/truecase.perl -model model/tc.$TRG < multi_data/$prefix.tok.$TRG > multi_data/$prefix.tc.$TRG
done

echo "fin 4"

# train BPE
cat multi_data/corpus.tc.$SRC1 multi_data/corpus.tc.$SRC2 multi_data/corpus.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > model/$SRC1$SRC2$TRG.bpe

# apply BPE
for prefix in corpus
do
    $subword_nmt/apply_bpe.py -c model/$SRC1$SRC2$TRG.bpe < multi_data/$prefix.tc.$SRC1 > multi_data/$prefix.bpe.$SRC1
    $subword_nmt/apply_bpe.py -c model/$SRC1$SRC2$TRG.bpe < multi_data/$prefix.tc.$SRC2 > multi_data/$prefix.bpe.$SRC2
    test -f multi_data/$prefix.tc.$TRG || continue
    $subword_nmt/apply_bpe.py -c model/$SRC1$SRC2$TRG.bpe < multi_data/$prefix.tc.$TRG > multi_data/$prefix.bpe.$TRG
done

echo "fin all"
