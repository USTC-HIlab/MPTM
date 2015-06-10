function mptmdb_validate(form) 
{
  var returnValue = false;
  var xmlhttp;
 if(form.mptmdb_search.value.length==0) {
	  	//returnValue=false;
			alert("\nPlease input several keywords!");
			form.mptmdb_search.focus();
returnValue=true;
	  }
if(window.XMLHttpRequest){
xmlhttp=new XMLHttpRequest();
}else{
xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
}
xmlhttp.onreadystatechange=function(){
if(xmlhttp.readyState==4 && xmlhttp.status==200){
document.getElementById("result").innerHTML=xmlhttp.responseText;
}
}
var mptmdb_search = document.getElementById("mptmdb_search").value;
var select = document.getElementById("select").value;
xmlhttp.open("GET","cgi-bin/mptmdb.cgi?mptmdb_search="+mptmdb_search+"&select="+select);
xmlhttp.send();
document.getElementById("result").innerHTML="<img  class='mptm_loading' src='images/loading.gif' />";
return returnValue;
}
 
