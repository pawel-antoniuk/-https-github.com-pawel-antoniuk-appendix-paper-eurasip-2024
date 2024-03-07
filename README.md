# Software Repository - Ensemble width estimation in HRTF-convolved binaural music recordings using an auditory model and a gradient-boosted decision trees regressor
This repository consists of the scripts and data intended to replicate the experiments described in the paper "Ensemble width estimation in HRTF-convolved binaural music recordings using an auditory model and a gradient-boosted decision trees regressor"

## Structure
The repository is organized as follows:
- [scripts](scripts) - scripts used in the development of the deep learning algorithm: finding hyperparameters, model traning, evaluation, visualization, and statistical calculations
- [animations](animations) - contains animations illustrating the impact of ensemble width on the ILD (Interaural Level Difference), ITD (Interaural Time Difference), and IC (Interaural Coherence)
- [figures](figures) - includes both the figures utilized in the paper and additional ones not featured

## Dependencies
Software dependencies:
- [MATLAB](https://www.mathworks.com/products/matlab.html): A development environment used to extract spatial features and perform post-analysis.
- [SOFA](https://github.com/sofacoustics/API_MO): A file format for reading, saving, and describing spatially oriented data of acoustic systems.
- [Python](https://www.python.org/): A programming language utilized for executing the training algorithms.
- [LightGBM](https://github.com/microsoft/LightGBM): A gradient boosting framework that employs tree-based learning algorithms.

## Authors
Paweł Antoniuk <sup>1</sup>, Sławomir K. Zieliński <sup>1</sup>, Hyunkook Lee <sup>2</sup>

<sup>1</sup> Faculty of Computer Science, Białystok University of Technology, 15-351 Białystok, Poland; s.zielinski@pb.edu.pl (S.K.Z.); p.antoniuk6@student.pb.edu.pl (P.A.)

<sup>2</sup> Applied Psychoacoustics Laboratory (APL), University of Huddersfield, Huddersfield HD1 3DH, UK; H.Lee@hud.ac.uk (H.L.)

## License
The content of this repository is licensed under the terms of the GNU General Public License v3.0 license. Please see the [LICENSE](LICENSE) file for more details.
