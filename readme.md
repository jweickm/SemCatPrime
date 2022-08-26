# Gender Stereotypes and Semantic Categorization in a Priming Paradigm

This repository contains the script and stimuli for a psychological computer experiment using Psychtoolbox for Matlab.

## Description

This experiment about visual perception tests whether stereotypes about men or women affect the reaction time. The participant has to discriminate adjectives according to their valence in a reaction time task. For primes we use male and female faces with either a happy or angry facial expression. To control for individual differences in the perception of the target stimuli, participants rate the stimuli for their valence without primes.

## Files

- `images` contains the prime stimuli used in the experiment
  - There is one face for each condition (sex × emotion).
  - For further statistical control we recommend to use multiple images for each condition.
- `experiment_tw.m` is the main experimental script to be run from Matlab.
- `target.mat` contains the list of target adjectives used in this study in a pre-assembled format.

## [Design of the Experiment](presentation_todorova_weickmann.pdf)
