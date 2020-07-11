DATA=../../../EX-MS/data/UN6WAY_Nolack_Multi_16

../../build/marian-decoder -i $DATA/test.es $DATA/test.fr -o output -m model/model.npz -v ./model/vocab.esfren.yml ./model/vocab.esfren.yml ./model/vocab.esfren.yml

perl /nmt/work/OpenNMT-py/tools/multi-bleu.perl $DATA/test.en  < output > test.result.bleu

