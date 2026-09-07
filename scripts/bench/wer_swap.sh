# usage: wer_swap.sh <путь к .mlmodelc энкодера> <куда писать json>
S=/private/tmp/claude-501/-Users-rafkat-Apps-rafkat-flowka-parakeet-v3/e00711e3-8de3-4f7c-a183-7f065dc59e01/scratchpad
M="$HOME/Library/Application Support/FluidAudio/Models/parakeet-tdt-0.6b-v3"
ENC="$1"; OUT="$2"
restore () {
  if [ -d "$M/Encoder.orig.mlmodelc" ]; then
    rm -rf "$M/Encoder.mlmodelc"; mv "$M/Encoder.orig.mlmodelc" "$M/Encoder.mlmodelc"
    echo "RESTORED $(du -sh "$M/Encoder.mlmodelc" | cut -f1)"
  fi
}
trap restore EXIT INT TERM
mv "$M/Encoder.mlmodelc" "$M/Encoder.orig.mlmodelc"
cp -R "$ENC" "$M/Encoder.mlmodelc"
echo "SWAPPED $(basename $ENC) ($(du -sh "$M/Encoder.mlmodelc" | cut -f1))"
$S/venv/bin/python $S/wer.py "$OUT"
