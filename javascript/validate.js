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
function validate_pmids(form) 
{
var returnValue = true;
var radios = document.getElementsByName("radio");  
                            
	  if(form.sequences.value.length==0 && form.fileUpload.value.length==0) {
	  	returnValue=false;
			alert("\nPlease input several PMIDs or upload a file!");
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

 
function validate_searchs(form) 
{
var returnValue = true;
var radios = document.getElementsByName("radio");  
var str=document.getElementById("selectptm").value;
	  if(form.searchkeys.value.length==0)
			{
			returnValue=false;
				alert("\nPlease input several keywords!");
				form.searchkeys.focus();
			}
		  else 
			{
			radios[1].checked=true;
radios[0].checked=false;
radios[2].checked=false;
 $('.mask').css({'display': 'block'});
        center($('.mess'));
        check($(this).parent(), $('.btn1'), $('.btn2'));
			return true;
			}
	                      
  return returnValue;
}



function validate_texts(form) 
{
var returnValue = true;
var radios = document.getElementsByName("radio");  
	  if(form.texts.value.length == 0) {
	  	returnValue=false;
		alert("\nPlease input your texts!");
		form.texts.focus();
	  }
	  else {
	radios[2].checked=true;
	radios[0].checked=false;
	radios[1].checked=false;
 $('.mask').css({'display': 'block'});
        center($('.mess'));
        check($(this).parent(), $('.btn1'), $('.btn2'));
		return true;
	  }

  
  return returnValue;
}
