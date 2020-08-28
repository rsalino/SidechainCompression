# SidechainCompression

## sidechain.m with main.wav and sidechain.wav
MATLAB implementation of sidechain compressor algorithm
(downmixes stereo inputs to mono because SHARC DSP board
to be used in the actual implementation only accepts one
input and one output, so will use left channel for one
signal and right channel for other)
main.wav and sidechain.wav are the signal to be compressed
and the signal to be compressed around (or be used as the
sidechain signal)

## callback_audio_processing.cpp
The meat of the SHARC audio DSP board programming - without
this device and the Analog Devices CrossCore Embedded Studio
software, it is useless. Given as demonstration of implementation.
