# written by dr.haol
# haolll@swu.edu.cn

rm(list = ls())
library(plyr); library(ggplot2); library(psych); library(ggpubr)
fig.dpi <- 300; fig.wid <- 12; fig.hei <- 12; fig.fmt <- "png"
fig.savedir <- "C:\\Users\\haolei\\Desktop"

setwd("D:\\Research\\2018_Hao_AttenNeuroDev\\Codes\\MakeFigures\\Fig5_GenRep")
data.fig <- read.csv("data_NewSample_r5dACC.csv")

data.viol <- ggplot(data = data.fig, 
                    aes(x = Group, y = Generalization.Index, color = Group, fill = Group)) +
  geom_violin(width = 0.8, size=1.5) +
  geom_boxplot(width = 0.3)+
  scale_color_manual(values=c(rgb(64/255,185/255,235/255),rgb(64/255,185/255,235/255),
                              rgb(64/255,185/255,235/255)), name = "Group", 
                     labels = c("Children", "Children", "Adults"), guide = "none") +
  scale_fill_manual(values=c("mediumaquamarine","lightseagreen","goldenrod1"), name = "Group", 
                    labels = c("Children", "Children","Adults"), guide = "none") +
  labs(x = " ", y = " ", title = " ") + 
  scale_x_discrete(breaks=c("g1ChildLow", "g2ChildHigh","g3Adults"), labels=c(" ", " "," ")) +
  # coord_cartesian(ylim=c(-1,3.2)) + 
  # scale_y_continuous(breaks=c(-1,1,3), labels=c(-1,1,3)) +
  theme(
    plot.title = element_text(size = 25, colour = "black", face = "bold", hjust = 0.5),
    axis.ticks = element_line(size = 0.6, colour = "black"),
    axis.ticks.length = unit(0.2, "cm"),
    axis.line.x = element_line(colour = "black", size = 0.8),
    axis.line.y = element_line(colour = "black", size = 0.8),
    axis.text.x = element_text(size = 15, colour = 'black'),
    axis.text.y = element_text(size = 15, colour = 'black'),
    axis.title = element_text(size = 20, colour = "black"),
    panel.background = element_rect(fill = "transparent"),
    plot.background = element_rect(fill = "transparent", color = NA),
    legend.background = element_rect(fill = "transparent"),
    legend.box.background = element_rect(fill = "transparent"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.title = element_text(size = 18),
    legend.text = element_text(size = 15),
    legend.position = "right")
data.viol

fig.name <- paste("fig5_dacc", ".", fig.fmt, sep = "")
ggsave(fig.name, path = fig.savedir, data.viol, 
       width=fig.wid, height=fig.hei, units="cm", dpi=fig.dpi, bg = "transparent")
