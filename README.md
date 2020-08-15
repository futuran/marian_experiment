# Quick Start

1. v.sh内のディレクトリ名を編集
```
export MARIAN_OUTPUT=/nmt/work/EX-MS/result/UN6WAY_Nolack_Multi_16/m5000_lr3e-4_s1
export MARIAN_DATA=/nmt/work/EX-MS/data/UN6WAY_Nolack_Multi_16
```
2. そのディレクトリを作成
```
mkdir nmt/work/EX-MS/result/UN6WAY_Nolack_Multi_16/m5000_lr3e-4_s1
```
3. さらにmodel, outputファイルも作成
```
mkdir nmt/work/EX-MS/result/UN6WAY_Nolack_Multi_16/m5000_lr3e-4_s1/model
mkdir nmt/work/EX-MS/result/UN6WAY_Nolack_Multi_16/m5000_lr3e-4_s1/output
```
4. v.sh内のコマンドを実行（環境変数へ書き込む）
```
export MARIAN_OUTPUT=/nmt/work/EX-MS/result/UN6WAY_Nolack_Multi_16/m5000_lr3e-4_s1
export MARIAN_DATA=/nmt/work/EX-MS/data/UN6WAY_Nolack_Multi_16
```
5. execute_200708.shを編集
6. execute_200708.shを実行
