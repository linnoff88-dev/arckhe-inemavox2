#!/bin/bash
# baixar-e-cortar.sh - Baixa vídeo do YouTube e corta em 4 partes

show_help() {
    echo "Uso: $0 URL TEMPO1 TEMPO2 TEMPO3 [TEMPO4]"
    echo ""
    echo "Exemplo:"
    echo "  $0 'https://youtube.com/watch?v=XXX' 00:15:00 00:30:00 00:45:00 01:00:00"
    echo "  $0 'https://youtube.com/watch?v=XXX' 00:15:00 00:30:00 00:45:00 fim"
    echo ""
    echo "TEMPO1, TEMPO2, TEMPO3: Pontos de corte (HH:MM:SS)"
    echo "TEMPO4: Fim da última parte ou 'fim' para até o final"
}

if [ $# -lt 4 ]; then
    show_help
    exit 1
fi

URL="$1"
TEMPO1="$2"
TEMPO2="$3"
TEMPO3="$4"
TEMPO4="${5:-fim}"

echo "================================"
echo "📥 BAIXAR E CORTAR VÍDEO"
echo "================================"
echo ""

# 1. Baixar vídeo
echo "📥 Baixando vídeo..."
yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]" \
       -o "video_completo.mp4" "$URL"

if [ $? -ne 0 ]; then
    echo "❌ Erro ao baixar vídeo"
    exit 1
fi

echo "✅ Download concluído!"
echo ""

# 2. Obter duraçêo do vídeo
DURACAO=$(ffprobe -v error -show_entries format=duration \
          -of default=noprint_wrappers=1:nokey=1 "video_completo.mp4")
echo "⏱️  Duraçêo do vídeo: $(printf '%02d:%02d:%02d\n' $((${DURACAO%.*}/3600)) $((${DURACAO%.*}%3600/60)) $((${DURACAO%.*}%60)))"
echo ""

# 3. Cortar em 4 partes
echo "✂️  Cortando vídeo em 4 partes..."
echo ""

echo "Cortando Parte 1 (00:00:00 → $TEMPO1)..."
ffmpeg -v quiet -stats -i "video_completo.mp4" -ss 00:00:00 -to "$TEMPO1" -c copy parte1.mp4
echo "✅ Parte 1 concluída"

echo "Cortando Parte 2 ($TEMPO1 → $TEMPO2)..."
ffmpeg -v quiet -stats -i "video_completo.mp4" -ss "$TEMPO1" -to "$TEMPO2" -c copy parte2.mp4
echo "✅ Parte 2 concluída"

echo "Cortando Parte 3 ($TEMPO2 → $TEMPO3)..."
ffmpeg -v quiet -stats -i "video_completo.mp4" -ss "$TEMPO2" -to "$TEMPO3" -c copy parte3.mp4
echo "✅ Parte 3 concluída"

if [ "$TEMPO4" = "fim" ]; then
    echo "Cortando Parte 4 ($TEMPO3 → fim)..."
    ffmpeg -v quiet -stats -i "video_completo.mp4" -ss "$TEMPO3" -c copy parte4.mp4
else
    echo "Cortando Parte 4 ($TEMPO3 → $TEMPO4)..."
    ffmpeg -v quiet -stats -i "video_completo.mp4" -ss "$TEMPO3" -to "$TEMPO4" -c copy parte4.mp4
fi
echo "✅ Parte 4 concluída"

echo ""
echo "================================"
echo "✅ PROCESSO CONCLUÍDO!"
echo "================================"
echo ""
echo "📁 Arquivos gerados:"
ls -lh video_completo.mp4 parte*.mp4
echo ""
echo "💡 Dica: Para deletar o vídeo completo e manter só as partes:"
echo "   rm video_completo.mp4"
