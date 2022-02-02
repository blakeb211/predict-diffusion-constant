# get dataframe into desired form
# (https://www.engineeringtoolbox.com/air-diffusion-coefficient-gas-mixture-temperature-d_2010.html)
dat <- read.table("diffusion.dat")
dat <- t(dat)
cnames <-
  dat[1,] # save molecular formula to be used as column names
dat <- matrix(as.double(dat), ncol = 8)

# clean data
dat <- dat[,-8]  # remove SF6
cnames <- cnames[-8] # remove SF6 from cnames
dat <- dat[-1,]   # remove first row
dat <- dat[-1,]  # remove 0 degree data since some missing

# label dataframe
temp <-
  c(20, 100, 200, 300, 400) # create vector to hold temp values
colnames(dat) <- cnames
rownames(dat) <- temp
# swap co2 and h2o columns
dat <- dat[, c("Ar", "CH4", "CO", "H2O", "H2", "CO2", "He")]
# swap cnames co2 and h2o
cnames = cnames[c(1, 2, 3, 6, 5, 4, 7)]

# add guessed features to dataframe
# molecular mass, kinetic diameter, dipole moment

# regression model yhat = t(x) %*% beta + nu
# x is feature vector

# fdat is the feature vector for the 7 molecules
fdat <- matrix(ncol = 3, nrow = 7)
fdat <- data.frame(fdat, row.names = cnames)
colnames(fdat) <- c("MM", "KDiam", "Dipole")
# add molar mass (g/mol)
fdat["MM"] <- c(39.95, 16.04, 28.01, 18.02, 2.02, 44.02, 4.00)
# add kinetic diameter (picometer) (https://en.wikipedia.org/wiki/Kinetic_diameter)
fdat["KDiam"] <- c(340, 380, 376, 265, 289, 330, 260)
# add dipole moment (Debye) (https://cccbdb.nist.gov/diplistx.asp)
fdat["Dipole"] <- c(0, 0, 0.112, 1.855, 0, 0, 0)


# check rms of each feature; consider altering to make rms similar size
# regularize rmses
fdat[, "KDiam"] <- fdat[, "KDiam"] * (1 / 1000)
fdat["MM"] <- 1 / sqrt(fdat["MM"])

rms <- function(x)
  sqrt(sum(x * x) / length(x))
# print out rms of features
# for (i in 1:3) {
#   res <- rms(fdat[, i])
#   print(paste0(colnames(fdat)[i], " = ", res))
# }

ls1 <-
  lsfit(
    fdat[1:5, ],
    t(dat[, 1:5]),
    wt = NULL,
    intercept = TRUE,
    tolerance = 1e-07
  )

# check model result on co2 and He
fco2 <- as.numeric(cbind(1, fdat["CO2", ]))
fhe <- as.numeric(cbind(1, fdat["He", ]))

model1 <- t(ls1$coefficients)
rownames(model1) <- temp

pred_co2 <- model1 %*% fco2
pred_he <- model1 %*% fhe
actual_co2 <- dat[, "CO2"]
actual_he <- dat[, "He"]

library("pracma")

# plot diffusion constant versus temp for the two species we'll predict, CO2 and He

plot_data <- data.frame(cbind(temp,actual_co2,pred_co2,actual_he,pred_he))
colnames(plot_data) <- c("Temp", "CO2 actual", "CO2 predicted", "He actual", "He predicted")

library("ggplot2")
colors <- c("CO2 actual" = "darkblue", "CO2 predicted" = "steelblue", 
            "He actual" = "darkred", 
            "He predicted" = "lightcoral")
ggplot(data=plot_data) + aes(x=Temp) + 
  geom_point(aes(y=`CO2 actual`,color ="CO2 actual")) + 
  geom_line(aes(y=`CO2 actual`,color="CO2 actual")) +
  geom_point(aes(y=`CO2 predicted`,color ="CO2 predicted")) + 
  geom_line(aes(y=`CO2 predicted`,color="CO2 predicted"),linetype="twodash") +
  geom_point(aes(y=`He actual`,color ="He actual")) + 
  geom_line(aes(y=`He actual`,color="He actual")) +
  geom_point(aes(y=`He predicted`,color ="He predicted")) + 
  geom_line(aes(y=`He predicted`,color="He predicted"),linetype="twodash") + 
  labs(x="Temp (C)", y=bquote('Diffusivity'~(cm^2 / s)), color="Legend") +
  scale_color_manual(values=colors) +
  theme(legend.position = c(0.2, 0.75)) +
  ggtitle("Predicting Diffusion Constants with a Linear Model") + 
  theme(plot.title = element_text(hjust = 0.5,size=10)) +
  theme(axis.title = element_text(size=10)) +
  theme(legend.text = element_text(size=8)) +
  theme(legend.title = element_text(size=9))
  
  ggsave(filename="model_predictions.jpg", height=4.3, width=4,units="in", dpi=200)
  
  cat("\nExperimental Diffusion Constants at Different Temps:\n")
  print(dat)
  
  cat("\nFeature Matrix:\n")
  print(fdat)

  cat("\nLinear Model:\n")
  print(model1)
  
  cat("\nThe (+/-) signs of the model coefficients show that diffusion constants\n
        are positively correlated with 1/sqrt(Molar Mass) and negatively\n
        correlated with Kinetic Diameter and Dipole Moment. This makes sense\n
        physically because larger molecules should bump into other molecules\n
        more and molecules with a dipole moment should interact more strongly with\n
        molecules around them which would slow them down.\n")
  
  # calculate diffusion limit of gases in air at these temperatures
  # diffusion limit is obtained from plugging Molar Mass = 1, Kinetic Diameter = 0, 
  # and Dipole Moment = 1 into the model.
  
  predDiffusionLimit = model1 %*% c(1, 1/sqrt(1), 0, 0)
  cat("\nThe predicted diffusion limit for a gas at each temperature:\n")
  colnames(predDiffusionLimit) <- "cm^2 / 2"
  print(predDiffusionLimit)