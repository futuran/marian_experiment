#!/bin/bash -v

echo $MARIAN_DATA
echo $MARIAN_OUTPUT

MARIAN=../../../../build

# if we are in WSL, we need to add '.exe' to the tool names
if [ -e "/bin/wslpath" ]
then
    EXT=.exe
fi

MARIAN_TRAIN=$MARIAN/marian$EXT
MARIAN_DECODER=$MARIAN/marian-decoder$EXT
MARIAN_VOCAB=$MARIAN/marian-vocab$EXT
MARIAN_SCORER=$MARIAN/marian-scorer$EXT

#DATA=../../../EX-MS/data/UN6WAY_esfrar
#OUTPUT=./result_es2en_marian_80

DATA=$MARIAN_DATA
OUTPUT=$MARIAN_OUTPUT/output
MODEL=$MARIAN_OUTPUT/model

# set chosen gpus
GPUS="0 1"
if [ $# -ne 0 ]
then
    GPUS=$@
fi
echo Using GPUs: $GPUS

# create common vocabulary
cat $DATA/train.esfr $DATA/train.en $DATA/valid.esfr $DATA/valid.en $DATA/test.esfr $DATA/test.en | $MARIAN_VOCAB --max-size 36000 > $MODEL/vocab.esfren.yml

# train model
if [ ! -e "$MODEL/model.npz" ]
then
    $MARIAN_TRAIN \
        --model $MODEL/model.npz --type transformer \
        --train-sets $DATA/train.esfr $DATA/train.en\
        --max-length 100 \
        --vocabs $MODEL/vocab.esfren.yml $MODEL/vocab.esfren.yml \
        --mini-batch-fit -w 5000 --maxi-batch 1000 \
        --early-stopping 10 --cost-type=ce-mean-words \
        --valid-freq 5000 --save-freq 5000 --disp-freq 500 \
        --valid-metrics ce-mean-words perplexity translation \
        --valid-sets $DATA/valid.esfr $DATA/valid.en \
        --valid-script-path "bash ./scripts/validate_tamura_200708.sh" \
        --valid-translation-output $OUTPUT/valid.esfr.output --quiet-translation \
        --valid-mini-batch 32 \
        --beam-size 6 --normalize 0.6 \
        --log $MODEL/train.log --valid-log $MODEL/valid.log \
        --enc-depth 6 --dec-depth 6 \
        --transformer-heads 8 \
        --transformer-postprocess-emb d \
        --transformer-postprocess dan \
        --transformer-dropout 0.1 --label-smoothing 0.1 \
        --learn-rate 0.0003 --lr-warmup 16000 --lr-decay-inv-sqrt 16000 --lr-report \
        --optimizer-params 0.9 0.98 1e-09 --clip-norm 5 \
        --tied-embeddings-all \
        --devices $GPUS --sync-sgd --seed 1111 \
        --exponential-smoothing
fi

