# written by dr.haol
# haolll@swu.edu.cn

### Basic information set up ###
rm(list = ls())                                                # Delete all variables in the current environment
library(ggsignif); library(ggplot2); library(ggpubr)           # Load and attach add-on packages
fig.dpi <- 300; fig.wid <- 20; fig.hei <- 12; fig.fmt <- "eps" # Set parameters of the figure
fig.savedir <- "C:\\Users\\haolei\\Desktop"                                   # Set the path where the picture will be saved

# The indicators name in the data file
condname.colname <- c("Grp_CBD_Speci_fdr05_r01_angular_b","Grp_CBD_Speci_fdr05_r02_tpj_b","Grp_CBD_Speci_fdr05_r03_dacc_r")


# The indicators name will present in the figure
condname.show <- condname.colname

# Read result file of basic information (.csv)
res.file <- "D:\\Research\\2018_Hao_AttenNeuroDev\\Results\\OldSample\\basic_CBDA_img5.csv"
data.index <- read.csv(res.file)


setwd ("D:\\Research\\2018_Hao_AttenNeuroDev\\Codes\\MultivarRSA") # Set the working directory
data.subcond <- c("c12", "c13", "c23") # Conditions of the figure
c12 <- merge(read.csv("within_12_con_CommSpeci_NewSample.csv"), data.index, by = "Scan_ID") # Read result file (.csv) of pair between alerting and orienting condition
c13 <- merge(read.csv("within_13_con_CommSpeci_NewSample.csv"), data.index, by = "Scan_ID") # Read result file (.csv) of pair between alerting and executive condition
c23 <- merge(read.csv("within_23_con_CommSpeci_NewSample.csv"), data.index, by = "Scan_ID") # Read result file (.csv) of pair between orienting and executive condition

### Make figure ###
# Convert the read data into a format recognized by the package
data.fig <- data.frame(matrix(NA,0,3))
for (icond in  c(1:length(data.subcond))) {
  for (icol in c(1:length(condname.colname))) {
    data.con <- data.frame(rep(condname.colname[icol], nrow(get(data.subcond[icond]))))
    data.ned <- data.frame(get(data.subcond[icond])[c("Conds",condname.colname[icol])])
    
    data.tem <- cbind(data.con, data.ned)
    colnames(data.tem) <- c("Index","Conds","Index.Data")
    
    data.fig <- rbind(data.fig, data.tem)
  }
}

# Set the figure parameters
data.barfig <- ggbarplot (data.fig,                            # The data frame of results
                          x = "Index", y = "Index.Data",       # Character string containing the name of x and y variable
                          title = " ", xlab = " ", ylab = " ", # The x axis, y axis and title content of the figure
                          add = "mean_se",                     # Adding another plot element
                          #width = 0.5,
                          add.params = list(size = 1.5),     # parameters (size) for the argument 'add'
                          #size = 0,                          # The size of points and outlines
                          color = "Conds", fill = "Conds",     # Outline color and fill color
                          position = position_dodge(0.8)) +    # Position adjustment
  
  # Customize the fill color for each condition
  scale_fill_manual(values=c("transparent", "transparent", "transparent"), name = "Conds", labels = c("ao","ac","oc")) +
  
  # Customize the color of error bar for each condition
  scale_color_manual(values=c("yellow3","mediumvioletred","darkcyan"), name = "Conds", labels = c("ao","ac","oc"), guide = FALSE) +
  
  # Position scales for discrete data of x axis
  # scale_x_discrete(breaks = condname.colname, labels = c('FEF+SPL','FEF','SPL')) +
  # scale_x_discrete(breaks = condname.colname, labels = c('AI','dACC','TPJ')) +
  scale_x_discrete(breaks = condname.colname, labels = c("","","")) + 
  
  # Limitation of y axis
  coord_cartesian(ylim = c(-0.07, 0.2)) +
  
  # Modify components of a theme according to your preferences
  theme(
    plot.title            = element_text(size = 15, colour = "black"),
    axis.ticks            = element_line(size = 0.6, colour = "black"),
    axis.ticks.length     = unit(0.2, "cm"),
    axis.line.x           = element_line(colour = "black", size = 0.8),
    axis.line.y           = element_line(colour = "black", size = 0.8),
    axis.text             = element_text(size = 15, colour = "black"),
    axis.text.x           = element_text(size = 15, colour = "black"),
    axis.title            = element_text(size = 20, colour = "black"),
    panel.background      = element_rect(fill = "transparent"),
    plot.background       = element_rect(fill = "transparent", color = NA),
    legend.background     = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    legend.position       = "none"
  )
data.barfig

# Name of the figure
fig.name <- paste("fig4_bar_rsa-spec.", fig.fmt, sep = "")
# Save figure to disk
ggsave(fig.name, path = fig.savedir, data.barfig, width = fig.wid, height = fig.hei, 
       units = "cm", dpi = fig.dpi, bg = "transparent")
