from google.cloud import speech_v1p1beta1 as speech
from google.cloud import translate_v2 as translate
from google.cloud import storage
import librosa
import gcsfs
import os 

# Initialize Speech and Translation clients
client = speech.SpeechClient()
translate_client = translate.Client()


# speech_file = "gs://audio-analysis-001/audio-files/Sample Recordings/airline-conversation.mp3"
# speech_file = "gs://audio-analysis-001/audio-files/Sample Recordings/Warid_help_line.mp3"
# speech_file = "gs://audio-analysis-001/audio-files/Sample Recordings/2656416DLP.mov". #Format not recognized
# speech_file = "gs://audio-analysis-001/audio-files/Sample Recordings/Malayalam-Audio.m4a" #Format not recognised.
speech_file = "gs://audio-analysis-001/audio-files/Sample Recordings/chinese-conversation.mp3"
#speech_file = "gs://audio-analysis-001/audio-files/Sample Recordings/sample-customer-recording.mp3"

first_lang = "en-US"
second_lang = ["ml-IN", "es", "cmn-Hans-CN", "cmn-Hans-CN", "cmn-Hans-HK", "cmn-Hant-TW", "yue-Hant-HK", "hi-IN"]

# Fetch file extension to determine the audio encoding
def audio_encoding_format(speech_file):
    _, ext = os.path.splitext(speech_file)
    ext = ext.lower()  # Convert to lowercase for case-insensitive comparison

    if ext == '.mp3':
        print(f"Audio format is: MP3")
        return speech.RecognitionConfig.AudioEncoding.MP3
    elif ext == '.wav':
        print(f"Audio format is: WAV")
        return speech.RecognitionConfig.AudioEncoding.LINEAR16
    elif ext == '.flac':
        print(f"Audio format is: FLAC")
        return speech.RecognitionConfig.AudioEncoding.FLAC
    # Add more elif blocks for other supported formats as needed
    else:
        print(f"No valid format found. Check the file extension")
        return None  # Or raise an exception if unsupported formats should be handled explicitly

# Calculate the audio duration
def audio_duration(speech_file):
    # Create a GCSFileSystem object
    fs = gcsfs.GCSFileSystem()

    # Open the audio file from GCS
    with fs.open(speech_file, 'rb') as f:
        # Load the audio using librosa
        y, sr = librosa.load(f)

    audio_duration_in_seconds = librosa.get_duration(y=y, sr=sr)

    print(f"Audio duration: {audio_duration_in_seconds} seconds")
    return audio_duration_in_seconds

def detect_language(transcript):
    """Detects the language of the given transcript using Cloud Translation."""
    result = translate_client.detect_language(transcript)
    return result['language']

def transcribe_audio(config, audio):
    # Use either 'recognize' (for audio <= 1 minute) or 'long_running_recognize' (for audio > 1 minute)
    if audio_duration_in_seconds <= 60:
        operation = client.recognize(config=config, audio=audio)
    else:
        operation = client.long_running_recognize(config=config, audio=audio)

    print("Waiting for operation to complete...")
    response = operation.result() 

    full_transcript = ""
    for result in response.results:
        full_transcript += result.alternatives[0].transcript
    return full_transcript

# audio = speech.RecognitionAudio(content=content)
audio = speech.RecognitionAudio(uri=speech_file)
audio_duration_in_seconds = audio_duration(speech_file)
audio_encoding_format = audio_encoding_format(speech_file)


# Initial transcription for language detection
initial_config = speech.RecognitionConfig(
    encoding=audio_encoding_format,
    sample_rate_hertz=44100,
    audio_channel_count=2,
    language_code=first_lang,    # Use the default language for initial detection
)

initial_transcript = transcribe_audio(initial_config, audio)
print("initial transcript ", initial_transcript)

# Detect language
detected_language = detect_language(initial_transcript)
print(f"Detected language: {detected_language}")

# Final transcription with detected language
final_config = speech.RecognitionConfig(
    encoding=audio_encoding_format,
    sample_rate_hertz=44100,
    audio_channel_count=2,
    language_code=detected_language, 
)

final_transcript = transcribe_audio(final_config, audio)
print(final_transcript)