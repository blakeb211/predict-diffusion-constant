# Overview
Predict diffusion constants at different temperatures for various types gases in air

# Prediction methods
- Linear least squares model
- See "analysis.R" for details. 
- Feature vectors were assembled for 7 small molecules with known diffusion constants at 5 different temperatures
- The model (coefficient) matrix was solved using 5 of the molecules and tested against the 2 remaining molecules.

# Feature Selection
- The feature selection was done manually. 
- Features: 1 / (molar mass)^0.5, kinetic diameter, dipole moment

# Summary
- <img src="model_predictions.jpg" width="400" height="430">
- This model has the strength of being easy to interpet. Increasing the molar mass decreases the diffusion constant. Increasing the kinetic diameter or the dipole moment decreases the diffusion constant.
- One interesting result is that the model predicts the diffusion limit for a gas at each temperature in the study, obtained by plugging the (MM = 1, KDiam = 0, Dipole = 0) feature vector into the model.
