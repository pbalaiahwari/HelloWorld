function print(){
 var i;
 var write = document.getElementsByTagName('h1')[0];
 for(i = 20; i <= 70; i++){
   if((i % 2) == 0){
    continue; //if num is odd, skip it.
   }
   write.innerHTML += i + '<br/>';
 }
}
print();