#==specify options (e.g. what management tactic is going to be searched over)
#==make storage facility for key output (e.g. total cost vs. total profit; depletion, spr)
#==create directories
#==write csv files
#==scenarios: changing MPA size, changing size limit, changing season length, changing effort input through fishers, etc.

require(animation)
require(caTools)
source("Master.R")
source("lenwei.R")
source("VisualizeMovement.R")
source("movArray.R")
source("InitialPop.R")
source("Recruitment.R")
source("samplingFunc.R")
#rm(list=ls())

Graphs<-F
GraphsFish<-F
PrintLifeHistory<-F

#==open access===========================

Life<-read.csv("LifeHistoryRARE.csv")                 # life history characteristics
SimCTL<-read.csv("GrandSimCtl.csv",header=F)               # simulation controls
Fleets<-read.csv("Fleets.csv",header=F)                   # fleet characteristics  
season<-read.csv("seasonNULL.csv",header=F)           # fishing seasons by fleet
Samp <- read.csv("SamplingParams.csv")            # sampling controls for management
NoTakeZoneNULL<-read.csv("notakezoneNULL.csv",header=F)   # marine protected areas (0=open access, 1=MPA, 2=TURF?)
NoTakeZoneImp<-read.csv("notakezone.csv",header=F)   # marine protected areas (0=open access, 1=MPA, 2=TURF?)
habitat<-read.csv("habitatNULL.csv",header=F)         # habitat quality (recruitment suitability)

OpenAccess<-Master(Life,SimCTL,Fleets,season,Samp,NoTakeZoneNULL,NoTakeZoneImp,habitat,Graphs=F,GraphsFish=F,PrintLifeHistory=F)
OAtotCatch<-apply(OpenAccess$CatchByFisher,2,sum,na.rm=T)
OAtotCost<-apply(OpenAccess$CostByFisher,2,sum,na.rm=T)
OAtotProfit<-apply(OpenAccess$ProfitByFisher,2,sum,na.rm=T)

tempMat<-matrix(0,ncol=10,nrow=10)
for(x in 1:275)
  tempMat<-tempMat+OpenAccess$SpaceEffort[x,,,]
sum(tempMat)
dev.off()
filled.contour(tempMat)

burnInt   <-SimCTL[grep('burn',SimCTL[,2]),1]
simTimePlt <-SimCTL[grep('simTime',SimCTL[,2]),1]
initManage<-SimCTL[grep('initManage',SimCTL[,2]),1]   # year in which to initiate management

par(mfrow=c(6,1),mar=c(.1,4,.1,.1))
plot(OAtotCatch,type="b",xaxt='n',las=2,ylim=c(0,max(OAtotCatch,na.rm=T)),ylab="Total Catch",pch=16)
abline(v=initManage,col=2,lty=2)
legend("topright",col=2,lty=2,"MPA implemented",bty='n')
plot(OAtotCost,lty=2,type="b",pch=16,xaxt='n',las=2,ylim=c(0,max(OAtotCost,na.rm=T)),ylab="Total cost of fishing")
abline(v=initManage,col=2,lty=2)

plot(OAtotProfit,lty=2,type="b",pch=16,xaxt='n',las=2,ylim=c(0,300),ylab="Total profit of fishing")
abline(v=initManage,col=2,lty=2)

plot(OpenAccess$CostOfManagement[1:(simTimePlt-burnInt)],pch=16,type="b",xaxt='n',las=2,ylim=c(0,max(OpenAccess$CostOfManagement,na.rm=T)),
     ylab="Cost of MPA")
abline(v=initManage,col=2,lty=2)

plot(OpenAccess$SpawningBiomass[burnInt:simTimePlt],pch=16,type="b",xaxt='n',las=2,
     ylab="SpawningBio",ylim=c(0,max(OpenAccess$SpawningBiomass[burnInt:simTimePlt],na.rm=T)))
abline(v=initManage,col=2,lty=2)
plot(OpenAccess$OutsideMPAspbio[burnInt:simTimePlt],ylim=c(0,max(OpenAccess$OutsideMPAspbio[burnInt:simTimePlt])),type='b',pch=16)
lines(OpenAccess$InsideMPAspbio[burnInt:simTimePlt],type='b',pch=16,col=2)
abline(v=initManage,col=2,lty=2)

legend("topright",col=c(1,2),pch=16,legend=c("Outside MPA","Inside MPA"),bty='n')


#== calculate statistics for before and after managmeent implementation
timeBack<-120
timeInd11<-initManage-timeBack-burnInt
timeInd12<-initManage-burnInt

timeInd21<-simTimePlt-burnInt-timeBack
timeInd22<-simTimePlt-burnInt

# timeInd21<-simTimePlt-burnInt-timeBack
# timeInd22<-simTimePlt-burnInt
sum(OAtotCatch[(timeInd11):(timeInd12)])
sum(OAtotCatch[(timeInd21):(timeInd22)])

sum(OAtotCost[(timeInd11):(timeInd12)])
sum(OAtotCost[(timeInd21):(timeInd22)])

sum(OAtotProfit[(timeInd11):(timeInd12)])
sum(OAtotProfit[(timeInd21):(timeInd22)])

sum(OpenAccess$SpawningBiomass[(timeInd11):(timeInd12)])
sum(OpenAccess$SpawningBiomass[(timeInd21):(timeInd22)])

sum(OpenAccess$OutsideMPAspbio[(timeInd11):(timeInd12)])
sum(OpenAccess$OutsideMPAspbio[(timeInd21):(timeInd22)])

sum(OpenAccess$InsideMPAspbio[(timeInd11):(timeInd12)])
sum(OpenAccess$InsideMPAspbio[(timeInd21):(timeInd22)])

Cat1<-mean(OAtotCatch[(timeInd11):(timeInd12)])
Cat2<-mean(OAtotCatch[(timeInd21):(timeInd22)])
(Cat2-Cat1)/Cat1

Cost1<-mean(OAtotCost[(timeInd11):(timeInd12)])
Cost2<-mean(OAtotCost[(timeInd21):(timeInd22)])
(Cost2-Cost1)/Cost1

Prof1<-mean(OAtotProfit[(timeInd11):(timeInd12)])
Prof2<-mean(OAtotProfit[(timeInd21):(timeInd22)])
(Prof2-Prof1)/Prof1

SpB1<-mean(OpenAccess$SpawningBiomass[(timeInd11):(timeInd12)])
SpB2<-mean(OpenAccess$SpawningBiomass[(timeInd21):(timeInd22)])
(SpB2-SpB1)/SpB1

MPAout1<-mean(OpenAccess$OutsideMPAspbio[(timeInd11):(timeInd12)])
MPAout2<-mean(OpenAccess$OutsideMPAspbio[(timeInd21):(timeInd22)])
(MPAout2-MPAout1)/MPAout1

MPAin1<-mean(OpenAccess$InsideMPAspbio[(timeInd11):(timeInd12)])
MPAin2<-mean(OpenAccess$InsideMPAspbio[(timeInd21):(timeInd22)])
(MPAin2-MPAin1)/MPAin1

DiffMPA<-cbind((OAtotCatch-MPAtotCatch)/OAtotCatch,(OAtotProfit-MPAtotProfit)/OAtotProfit,
 (OpenAccess$SpawningBiomass[burnIn:simTimePlt]-halfMPA$SpawningBiomass[burnIn:simTimePlt])/OpenAccess$SpawningBiomass[burnIn:simTimePlt]
step1<-251
step2<-281
sum(OAtotCatch[step1:step2])
sum(MPAtotCatch[step1:step2])

sum(OAtotProfit[step1:step2])
sum(MPAtotProfit[step1:step2])

sum(OpenAccess$SpawningBiomass[step1:step2])
sum(halfMPA$SpawningBiomass[step1:step2])
sum((OpenAccess$SpawningBiomass[step1:step2]-halfMPA$SpawningBiomass[step1:step2]))/(OpenAccess$SpawningBiomass[step1:step2]))

dev.off()
boxplot(DiffMPA,ylim=c(-2,2))

#saveHTML(ani.replay(), img.name = "record_plot_oldf",outdir = getwd(),interval=0.05)
