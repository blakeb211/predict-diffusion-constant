# predict_diffusion_constant
predict diffusion constant at different temperatures for different types of gas in air

# Prediction methods
- Linear least squares model
- See "analysis.R" for details. I created feature vectors for 7 small molecules that I had diffusion constant data for. Then I solved for the coefficient matrix using 5 of the molecules and tested it (see image below) on the 2 remaining molecules.
  - feature vectors: molar mass, kinetic diameter, dipole moment
  - <img src="model_predictions.jpg" width="400" height="430">
