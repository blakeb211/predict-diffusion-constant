# get dataframe into desired form
dat <- read.table("diffusion.dat")
dat <- t(dat)
cnames <- dat[1,] # save molecular formula to be used as column names
dat <- matrix(as.double(dat),ncol=8)

# clean data
dat <- dat[,-8]  # remove SF6
cnames <- cnames[-8] # remove SF6 from cnames
dat <- dat[-1,]   # remove first row
dat <- dat[-1,]  # remove 0 degree data since some missing

# label dataframe
temp <- c(20,100,200,300,400) # create vector to hold temp values
colnames(dat) <- cnames
rownames(dat) <- temp
# swap co2 and h2o columns
dat <- dat[, c("Ar", "CH4", "CO", "H2O", "H2", "CO2", "He")]

# plot diffusion constant versus temp for each species
ar <- dat[,"Ar"]
ch4 <- dat[,"CH4"]
co <- dat[,"CO"]
h2o <- dat[,"H2O"]
h2 <- dat[,"H2"]

jpeg('diffusivity_vs_T_training_data.jpg')
plot(temp,ar,type="b",ylab="diffusivity (cm^2/s)", xlab="temp (deg C)", ylim=c(0,3),xlim=c(20,400))
points(temp,ch4, type="b", col = "green")
points(temp,co, type="b", col = "blue")
points(temp,h2o, type="b", col = "magenta")
points(temp,h2, type="b", col = "red")
# Add a legend
legend(20, 2.5, legend=c("Ar", "CH4", "CO", "H2O", "H2"), col=c("black", "green", "blue", "magenta", "red"), lty =1:2, cex=0.8)
dev.off()

# add guessed features to dataframe
# molecular mass, molecular diameter, polarizability, dipole moment