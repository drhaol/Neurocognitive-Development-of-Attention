# written by dr.haol
# haolll@swu.edu.cn

### Basic information set up ###
rm(list = ls())                                                # Delete all variables in the current environment
library(ggplot2); library(ggpubr);library(see)                              # Load and attach add-on packages
fig.dpi <- 300; fig.wid <- 8; fig.hei <- 10; fig.fmt <- "eps" # Set parameters of the figure

setwd("D:/Documents/BaiduSyncdisk/Research/2018_Hao_AttenNeuroDev/Codes/DissocDegr")                             # Set the working directory
condname.colname <- "EucliDist"
condname.figshow <- "EucliDist"

data.grp    <- "CBD"                     # Group of the data
data.subgrp <- c("g1CBDC", "g2CBDA")         # Subgroups of the data
g1CBDC <- read.csv("dissoc_degr_overall_g1C.csv") # Read result file of basic information (.csv) for subgroup 1
g2CBDA <- read.csv("dissoc_degr_overall_g2A.csv") # Read result file of basic information (.csv) for subgroup 2

### Make figure ###
# Convert the read data into a format recognized by the package
data.fig <- data.frame(matrix(NA,0,3))
for (igrp in  c(1:length(data.subgrp))) {
  for (icond in c(1:length(condname.figshow))) {
    data.con <- data.frame(rep(condname.figshow[icond], nrow(get(data.subgrp[igrp]))))
    data.ned <- data.frame(get(data.subgrp[igrp])[c("Group",condname.colname[icond])])
    
    data.tem <- cbind(data.con, data.ned)
    colnames(data.tem) <- c("Index","Group","Index.Data")
    
    data.fig <- rbind(data.fig, data.tem)
  }
}

# Set the figure parameters
fig.out <- ggplot(data = data.fig, 
                  aes(x = Group, y = Index.Data)) +
  geom_violinhalf(width = 0.8,aes(color=Group,fill=Group),position = position_nudge(x =.25, y = 0)) +
  #see::geom_violinhalf(width = 2, position = position_dodge(1.2))+
  geom_jitter(size=0.8,aes(color=Group),position = position_jitter(0.1))+
  geom_boxplot(width = 0.18,linewidth=0.8,aes(color=Group),position = position_nudge(x = .25, y = 0))+
  
  # Add mean comparison p-values to the plot
  # stat_compare_means(aes(group=Group), method="t.test", label.y=c(50,50,50), label="p.signif", size=4) +                     
  
  # Customize the color of error bar for each group
  scale_color_manual(values=c("lightseagreen","goldenrod1"), name = "Group", labels = c("Children", "Adults"), guide = "none") +             
  
  # Customize the fill color for each group
  scale_fill_manual(values=c("lightseagreen","goldenrod1"), name = "Group", labels = c("Children", "Adults"), guide = "none") +
  
  # Position scales for continuous data of y axis
  scale_y_continuous(limits=c(20,55)) +
  
  labs(x=" ", y=" ", title=" ") +
  
  # Modify components of a theme according to your preferences
  theme(
    plot.title            = element_text(size = 15, colour = "black", face = "bold", hjust = 0.5),
    axis.ticks            = element_line(size = 0.6, colour = "black"),
    axis.ticks.length     = unit(0.2, "cm"),
    axis.line.x           = element_line(colour = "black", size = 0.8),
    axis.line.y           = element_line(colour = "black", size = 0.8),
    axis.text.x           = element_text(size = 0, colour = 'black',),
    axis.text.y           = element_text(size = 15, colour = 'black'),
    axis.title            = element_text(size = 20, colour = "black"),
    panel.background      = element_rect(fill = "transparent"),
    plot.background       = element_rect(fill = "transparent", color = NA),
    legend.background     = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    legend.title          = element_text(size = 18),
    legend.text           = element_text(size = 15),
    legend.position       = "right")
fig.out
# Name of the figure
fig.name <- paste("fig_dissocdegr_overall.", fig.fmt, sep = "")
# Save figure to disk
ggsave(fig.name, path = getwd(), fig.out, width=fig.wid, height=fig.hei, 
       units="cm", dpi=fig.dpi, bg="transparent")
