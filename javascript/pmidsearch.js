 function center(obj) {
       
        var screenWidth = $(window).width(), screenHeight = $(window).height();  //当前浏览器窗口的 宽高
        var scrolltop = $(document).scrollTop();//获取当前窗口距离页面顶部高度
   
        var objLeft = (screenWidth - obj.width())/2 ;
        var objTop = (screenHeight - obj.height())/2 + scrolltop;

        obj.css({left: objLeft + 'px', top: objTop + 'px','display': 'block'});
        //浏览器窗口大小改变时
        $(window).resize(function() {
            screenWidth = $(window).width();
            screenHeight = $(window).height();
            scrolltop = $(document).scrollTop();
           
            objLeft = (screenWidth - obj.width())/2 ;
            objTop = (screenHeight - obj.height())/2 + scrolltop;
           
            obj.css({left: objLeft + 'px', top: objTop + 'px','display': 'block'});
           
        });
        //浏览器有滚动条时的操作、
        $(window).scroll(function() {
            screenWidth = $(window).width();
            screenHeight = $(window).height();
            scrolltop = $(document).scrollTop();
           
            objLeft = (screenWidth - obj.width())/2 ;
            objTop = (screenHeight - obj.height())/2 + scrolltop;
           
            obj.css({left: objLeft + 'px', top: objTop + 'px','display': 'block'});
        });
       
    }
function search_pmids(form) 
{
	var objs = document.getElementsByTagName("input"); 
    allValues='';      
    for(var i =1;i<objs.length;i++){    
        var obj = objs[i];    
        if(obj.checked){  
            allValues+=obj.value+",";     
        }  
       }    
    document.getElementById("sequences").value=allValues;
	var returnValue = true;
	var radios = document.getElementsByName("radio");             
	  if(document.getElementById("sequences").value.length==0) {
			returnValue=false;
			alert("\nPlease select at least one record!");
			form.sequences.focus();
	  }
	  else {
		radios[0].checked=true;
		radios[1].checked=false;
		radios[2].checked=false;
		 $('.mask').css({'display': 'block'});
				center($('.mess'));
				check($(this).parent(), $('.btn1'), $('.btn2'));

		return true;
	  }
  return returnValue;
}

