export PS1="\u@\h:\w$ "

#  aliases
alias ll='ls -lna'
alias rmtro='mount -o ro,remount / && (mount | grep root)'
alias rmtrw='mount -o rw,remount / && (mount | grep root)'
alias whoson='SN="$( ifconfig | grep -e '\''Bcast'\'' |  awk '\''{print $2}'\'' | sed s'\''/addr://'\'' | cut -d"." -f1-3 )"  ; for i in `seq 1 254`; do NAME="$( nslookup $SN.$i | grep -e '\''name'\'' | sed s'\''/^.*name = //'\'' )" ; if [ ! -z "$NAME" ] ;then ( ping  -w1 $SN.$i 2>&1 > /dev/null ; [ $? -eq 0 ] && echo $SN.$i = $NAME)  ; fi ; done '
alias timestamp="(date +'%F-%T' | sed  's/[:]//g')"
