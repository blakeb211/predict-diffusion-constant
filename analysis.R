# get dataframe into desired form
# (https://www.engineeringtoolbox.com/air-diffusion-coefficient-gas-mixture-temperature-d_2010.html)
dat <- read.table("diffusion.dat")
dat <- t(dat)
cnames <-
  dat[1, ] # save molecular formula to be used as column names
dat <- matrix(as.double(dat), ncol = 8)

# clean data
dat <- dat[, -8]  # remove SF6
cnames <- cnames[-8] # remove SF6 from cnames
dat <- dat[-1, ]   # remove first row
dat <- dat[-1, ]  # remove 0 degree data since some missing

# label dataframe
temp <- c(20, 100, 200, 300, 400) # create vector to hold temp values
colnames(dat) <- cnames
rownames(dat) <- temp
# swap co2 and h2o columns
dat <- dat[, c("Ar", "CH4", "CO", "H2O", "H2", "CO2", "He")]

# plot diffusion constant versus temp for each species
ar <- dat[, "Ar"]
ch4 <- dat[, "CH4"]
co <- dat[, "CO"]
h2o <- dat[, "H2O"]
h2 <- dat[, "H2"]

plot(
  temp,
  ar,
  type = "b",
  ylab = "diffusivity (cm^2/s)",
  xlab = "temp (deg C)",
  ylim = c(0, 3),
  xlim = c(20, 400)
)
points(temp, ch4, type = "b", col = "green")
points(temp, co, type = "b", col = "blue")
points(temp, h2o, type = "b", col = "magenta")
points(temp, h2, type = "b", col = "red")
# Add a legend
legend(
  20,
  2.5,
  legend = c("Ar", "CH4", "CO", "H2O", "H2"),
  col = c("black", "green", "blue", "magenta", "red"),
  lty = 1:2,
  cex = 0.8
)
dev.copy(jpeg, 'diffusivity_vs_T_training_data.jpg')
dev.off()

# add guessed features to dataframe
# molecular mass, kinetic diameter, polarizability, dipole moment

# regression model yhat = t(x) %*% beta + nu
# x is feature vector

fdat <- matrix(ncol = 4, nrow = 7)
fdat <- data.frame(fdat, row.names = cnames)
colnames(fdat) <- c("MM", "KDiam", "Polar.", "Dipole")
# add molar mass (g/mol)
fdat["MM"] <- c(39.95, 16.04, 28.01, 44.01, 2.02, 18.02, 4.00)
# add kinetic diameter (picometer) (https://en.wikipedia.org/wiki/Kinetic_diameter)
fdat["KDiam"] <- c(340, 380, 376, 330, 289, 265, 260)
# add dipole moment (Debye) (https://cccbdb.nist.gov/diplistx.asp)
fdat["Dipole"] <- c(0, 0, 0.112, 0, 0, 1.855, 0)
# polarizabilities (Angstrom^3)
fdat["Polar."] <- c(1.664, 2.448, 1.953, 2.507, 0.787, 1.501, 0.208)
