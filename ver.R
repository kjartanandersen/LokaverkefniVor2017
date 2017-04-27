#6
firstname <- c("Aaron A","Aaron A","Aaron A","Aaron A","Baldur","Baldur","Baldur","Baldur","Hildur","Hildur","Hildur","Hildur","Kjartan","Kjartan","Kjartan","Kjartan","Halldor","Halldor","Halldor","Halldor","Patrick","Patrick","Patrick","Patrick")
lastname <- c("Aronson","Aronson","Aronson","Aronson","Hanson","Hanson","Hanson","Hanson","Jonsdottir","Jonsdottir","Jonsdottir","Jonsdottir","Kjartansson","Kjartansson","Kjartansson","Kjartansson","Ivarsson","Ivarsson","Ivarsson","Ivarsson","Boivin","Boivin","Boivin","Boivin")
dateofbirth <- c("23/09/93","23/09/93","23/09/93","23/09/93","19/04/93","19/04/93","19/04/93","19/04/93","30/04/87","30/04/87","30/04/87","30/04/87","23/09/96","23/09/96","23/09/96","23/09/96","01/02/94","01/02/94","01/02/94","01/02/94","26/06/93","26/06/93","26/06/93","26/06/93")
betterDates <- as.Date(dateofbirth, "%d/%m/%y")
course <- c("GSF3A3U","WIN3B3DU","CNA3C3DU","LIN3A3U","GSF3A3U","WIN3B3DU","CNA3C3DU","LIN3A3U","GSF3A3U","WIN3B3DU","CNA3C3DU","LIN3A3U","GSF3A3U","WIN3B3DU","CNA3C3DU","LIN3A3U","GSF3A3U","WIN3B3DU","CNA3C3DU","LIN3A3U","GSF3A3U","WIN3B3DU","CNA3C3DU","LIN3A3U")
grade <- c(4.5,6,7,5,7,8,4,6,7.1,6.5,7,8,9,4.5,6.2,7.2,9,10,9,8,6.7,8.6,5.7,8.4)
df <- data.frame(firstname,lastname,betterDates,course,grade)


