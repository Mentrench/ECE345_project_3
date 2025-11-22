# ECE345_project_3


# Communication Systems Project - ECE 345

## Overview

This project explores the fundamentals of analog and digital modulation techniques, focusing on AM (Amplitude Modulation) and QAM (Quadrature Amplitude Modulation). We simulate the transmission of a message signal through an additive white Gaussian noise (AWGN) channel, perform modulation, demodulation, and analyze the impact of noise on communication systems. 

## Project Breakdown

### 1. **Analog Modulation (AM)**

In this section, we simulate the process of transmitting an analog message signal, modulating it onto a high-frequency carrier wave, and then adding noise to simulate the channel. The goal is to explore the effects of noise on the received signal and attempt to recover the original message.

- **Functions Involved**: 
  - `upconvert()`: Used to modulate the baseband signal onto a carrier.
  - `downconvert()`: Demodulates the received signal from passband back to baseband.

- **Key Concepts**:
  - Amplitude Modulation (AM)
  - Carrier frequency: 1310 kHz
  - Baseband message signal sampled at 44.1 kHz, upconverted to 10 MHz.
  
### 2. **Digital Modulation (4-QAM)**

In this section, we implement a 4-QAM digital modulation scheme to encode binary data into a modulated signal. The modulation and demodulation are simulated, including noise interference and the effect on the received signal.

- **Functions Involved**: 
  - `QAMmod()`: Encodes bits into QAM modulated waveforms.
  - `QAMdemod()`: Decodes the modulated signal back into bits.
  
- **Key Concepts**:
  - QAM Symbol Mapping
  - Bit Error Rate (BER) analysis as a function of Signal-to-Noise Ratio (SNR)
  - Pulse shaping and matched filters for demodulation

### 3. **Simulation & Evaluation**

We run the full system simulation, from encoding bits into QAM symbols, modulating them, passing them through the noise channel, and demodulatin
