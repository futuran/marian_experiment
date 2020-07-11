#!/bin/bash -v

MARIAN=../../build

# if we are in WSL, we need to add '.exe' to the tool names
if [ -e "/bin/wslpath" ]
then
    EXT=.exe
fi

MARIAN_TRAIN=$MARIAN/marian$EXT
MARIAN_DECODER=$MARIAN/marian-decoder$EXT
MARIAN_VOCAB=$MARIAN/marian-vocab$EXT
MARIAN_SCORER=$MARIAN/marian-scorer$EXT

DATA=../../../EX-MS/data/UN6WAY_Nolack_Multi_16
OUTPUT=./result_Nolack_Multi_16

# set chosen gpus
GPUS="0 1"
if [ $# -ne 0]
then
    GPUS=$@
fi
echo Using GPUs: $GPUS

cat $DATA/train.es $DATA/train.fr $DATA/train.en $DATA/valid.es $DATA/valid.fr $DATA/valid.en $DATA/test.es $DATA/test.fr $DATA/test.en | $MARIAN_VOCAB --max-size 36000 > model/vocab.esfren.yml

# train model
if [ ! -e "model/model.npz" ]
then
    $MARIAN_TRAIN \
        --model model/model.npz --type shared-multi-transformer \
        --train-sets $DATA/train.es $DATA/train.fr $DATA/train.en \
        --max-length 100 \
        --vocabs model/vocab.esfren.yml model/vocab.esfren.yml model/vocab.esfren.yml \
        --mini-batch-fit -w 7000 --maxi-batch 1000 \
        --early-stopping 10 --cost-type=ce-mean-words \
        --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
        --valid-metrics ce-mean-words perplexity translation \
        --valid-sets $DATA/valid.es $DATA/valid.fr $DATA/valid.en \
        --valid-script-path "bash ./scripts/validate.sh" \
        --valid-translation-output $OUTPUT/valid.en.output --quiet-translation \
        --valid-mini-batch 64 \
        --beam-size 6 --normalize 0.6 \
        --log model/train.log --valid-log model/valid.log \
        --enc-depth 6 --dec-depth 6 \
        --transformer-heads 8 \
        --transformer-postprocess-emb d \
        --transformer-postprocess dan \
        --transformer-dropout 0.1 --label-smoothing 0.1 \
        --learn-rate 0.00005 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
        --tied-embeddings-all \
        --devices $GPUS --sync-sgd --seed 1111 \
        --exponential-smoothing
fi


