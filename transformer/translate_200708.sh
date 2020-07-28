#!/bin/bush -v
../../../../build/marian-decoder -i $MARIAN_DATA/test.esfr -o output -m $MARIAN_OUTPUT/model/model.npz -v $MARIAN_OUTPUT/model/vocab.esfren.yml $MARIAN_OUTPUT/model/vocab.esfren.yml
perl /nmt/work/OpenNMT-py/tools/multi-bleu.perl $MARIAN_DATA/test.en < output > test.result.bleu

