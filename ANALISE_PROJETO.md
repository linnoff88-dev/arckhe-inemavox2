# Análise do Projeto inemaVOX (Dublar v4)

## O que é o projeto?

**inemaVOX** é uma **suite de voz com IA local** para processamento de vídeos. Dubla, transcreve, corta e baixa vídeos usando modelos rodando diretamente na GPU, sem dependência de APIs externas.

---

## Arquitetura do Pipeline (10 etapas)

```
VÍDEO → Extraçêo de Áudio → Transcriçêo → Traduçêo → Segmentaçêo
      → TTS (síntese de voz) → Fade → Sincronizaçêo → Concatenaçêo
      → Pós-processamento → Muxing → VÍDEO DUBLADO
```

### Detalhamento das Etapas

1. **Extraçêo de Áudio** - FFmpeg extrai áudio WAV 48kHz, 16-bit mono
2. **Transcriçêo** - Whisper ou Parakeet converte fala em texto com timestamps
3. **Traduçêo** - M2M100 ou Ollama traduz mantendo contexto
4. **Segmentaçêo** - Divide segmentos longos (máx. 10s por padrêo)
5. **TTS** - Sintetiza áudio dublado para cada segmento
6. **Fade** - Aplica fade-in/out de 10ms para evitar cliques
7. **Sincronizaçêo** - Ajusta duraçêo do áudio para coincidir com original
8. **Concatenaçêo** - Une todos os segmentos de áudio
9. **Pós-processamento** - Normaliza e comprime áudio
10. **Muxing** - Combina vídeo original com áudio dublado

---

## Tecnologias Principais

| Categoria | Opções |
|-----------|--------|
| **ASR (Transcriçêo)** | Faster-Whisper, NVIDIA Parakeet |
| **Traduçêo** | M2M100 (offline), Ollama (LLM local) |
| **TTS (Voz)** | Edge TTS (padrêo), Bark, Piper, XTTS (clonagem) |
| **Áudio** | FFmpeg, librosa, Rubberband |
| **Deep Learning** | PyTorch, Transformers |

### Dependências Principais

- **PyTorch** (≥2.0.0) - Framework de deep learning
- **Transformers** (≥4.30.0) - Modelos Hugging Face
- **Faster-Whisper** (≥1.0.0) - Reconhecimento de fala otimizado
- **Edge TTS** - Vozes neurais da Microsoft
- **FFmpeg** - Manipulaçêo de vídeo/áudio

---

## Arquivos Principais

| Arquivo | Funçêo | Linhas |
|---------|--------|--------|
| `dublar_pro_v4.py` | Script principal (v4) | 2.780 |
| `dublar_pro.py` | Versêo anterior (v3) | 2.187 |
| `test_parakeet.py` | Testes comparativos ASR | ~150 |
| `requirements.txt` | Dependências Python | 73 |
| `instalar.sh` | Script de instalaçêo Linux | ~150 |

---

## Recursos Avançados

### Presets de Qualidade

| Preset | Características |
|--------|-----------------|
| **rapido** | Edge TTS + M2M100 + Whisper medium |
| **balanceado** | Edge TTS + M2M100 + Whisper large-v3 + smart sync |
| **maximo** | XTTS/Edge TTS + Ollama + Whisper large-v3 + diarizaçêo |

### Funcionalidades

- **Traduçêo contextual** - Mantém consistência entre segmentos usando memória dos últimos 3 segmentos
- **Diarizaçêo** - Detecta múltiplos falantes e usa vozes diferentes para cada um
- **Clonagem de voz** - Copia a voz original do vídeo usando XTTS
- **YouTube** - Download direto via URL com yt-dlp
- **Sistema de checkpoint** - Permite retomar processamento interrompido
- **Métricas de qualidade** - Relatório JSON com tempos e qualidade por segmento

---

## Exemplos de Uso

### Básico

```bash
# Dublar para português (detecta idioma automaticamente)
python dublar_pro_v4.py --in video.mp4 --tgt pt

# Especificar idioma de origem
python dublar_pro_v4.py --in video.mp4 --src en --tgt pt
```

### YouTube

```bash
python dublar_pro_v4.py --in "https://youtube.com/watch?v=XXX" --tgt pt
```

### Avançado

```bash
# Com traduçêo Ollama (mais natural)
python dublar_pro_v4.py --in video.mp4 --tgt pt --tradutor ollama --modelo qwen2.5:14b

# Clonagem de voz
python dublar_pro_v4.py --in video.mp4 --tgt pt --clonar-voz

# Múltiplos falantes
python dublar_pro_v4.py --in video.mp4 --tgt pt --diarize

# Qualidade máxima
python dublar_pro_v4.py --in video.mp4 --tgt pt --qualidade maximo

# Voz e velocidade personalizadas
python dublar_pro_v4.py --in video.mp4 --tgt pt --voice pt-BR-FranciscaNeural --rate "+10%"
```

---

## Estrutura de Diretórios

### Saída Final

```
dublado/
└── video_dublado.mp4         ← Vídeo final dublado
```

### Arquivos de Trabalho

```
dub_work/
├── audio_src.wav             ← Áudio extraído do vídeo
├── asr.json                  ← Transcriçêo em JSON
├── asr.srt                   ← Transcriçêo em SRT
├── asr_trad.json             ← Traduçêo em JSON
├── asr_trad.srt              ← Traduçêo em SRT
├── seg_0001.wav ... seg_NNNN.wav  ← Segmentos TTS
├── dub_raw.wav               ← Áudio concatenado
├── dub_final.wav             ← Áudio pós-processado
├── diarization.json          ← Informaçêo de falantes
├── segments.csv              ← Métricas por segmento
├── quality_metrics.json      ← Relatório de qualidade
├── logs.json                 ← Log de execuçêo
└── checkpoint.json           ← Estado para retomada
```

---

## Pontos Fortes

1. **Robustez**
   - Sistema de checkpoints para retomar processamento
   - Fallbacks automáticos (Ollama → M2M100, XTTS → Edge TTS)
   - Normalizaçêo segura de áudio (trata NaN, Inf, clipping)

2. **Flexibilidade**
   - 4 engines de TTS (Edge, Bark, Piper, XTTS)
   - 2 engines de ASR (Whisper, Parakeet)
   - 2 engines de traduçêo (M2M100, Ollama)
   - 4 modos de sincronizaçêo (none, pad, fit, smart)

3. **Qualidade**
   - Traduçêo contextual com memória
   - CPS matching para sincronizaçêo precisa
   - Clonagem de voz para dublagem personalizada
   - Diarizaçêo para múltiplos falantes

4. **Performance**
   - Processamento paralelo de segmentos (ThreadPoolExecutor)
   - TTS assíncrono (Edge TTS)
   - Suporte a GPU (CUDA)
   - Time-stretching otimizado com Rubberband

---

## Commits Recentes

- Adiçêo do NVIDIA Parakeet como engine ASR alternativo
- Modelo Ollama padrêo alterado para qwen2.5:14b
- Melhorias na limpeza de respostas do Ollama
- Filtros de padrões inválidos nas traduções

---

*Documento gerado em: Janeiro 2026*
