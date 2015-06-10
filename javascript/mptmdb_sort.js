/**
 * Created by zang on 2015/3/20.
 */

/**
 * 通过表头对表列进行排序
 *
 * @param sTableID
 *            要处理的表ID<table id=''>
 * @param iCol
 *            字段列id eg: 0 1 2 3 ...
 * @param sDataType
 *            该字段数据类型 int,float,date 缺省情况下当字符串处理
 */
function  sortTable(sTableID, iCol, sDataType) {
    var  oTable = document.getElementById(sTableID);
    var  oTBody = oTable.tBodies[0];
    var  colDataRows = oTBody.rows;
    var  aTRs =  new  Array;
    for  (  var  i = 0; i < colDataRows.length; i++) {
        aTRs[i] = colDataRows[i];
    }
    if  (oTable.sortCol == iCol) {
        aTRs.reverse();
    }  else  {
        aTRs.sort(generateCompareTRs(iCol, sDataType));
    }
    var  oFragment = document.createDocumentFragment();
    for  (  var  j = 0; j < aTRs.length; j++) {
        oFragment.appendChild(aTRs[j]);
    }
    oTBody.appendChild(oFragment);
    oTable.sortCol = iCol;
}

/**
 * 比较函数生成器
 *
 * @param iCol
 *            数据行数
 * @param sDataType
 *            该行的数据类型
 * @return
 */
function  generateCompareTRs(iCol, sDataType) {
    return   function  compareTRs(oTR1, oTR2) {
        vValue1 = convert(oTR1.cells[iCol].firstChild.nodeValue, sDataType);
        vValue2 = convert(oTR2.cells[iCol].firstChild.nodeValue, sDataType);
        if  (vValue1 < vValue2) {
            return  -1;
        }  else   if  (vValue1 > vValue2) {
            return  1;
        }  else  {
            return  0;
        }
    };
}


/**
 * 处理排序的字段类型
 *
 * @param sValue
 *            字段值 默认为字符类型即比较ASCII码
 * @param sDataType
 *            字段类型 对于date只支持格式为mm/dd/yyyy或mmmm dd,yyyy(January 12,2004)
 * @return
 */
function  convert(sValue, sDataType) {
    switch  (sDataType) {
        case   "int" :
            return  parseInt(sValue);
        case   "float" :
            return  parseFloat(sValue);
        case   "date" :
            return new Date(Date.parse(sValue));
        default :
            return  sValue.toString();
    }
}

function selall_none(){
    var achked=new Array;
    var achk=[
        "Phosphorylation",
        "Methylation",
        "Glycosylation",
        "Acetylation",
        "Hydroxylation",
        "Myristoylation",
        "Amidation",
        "Sulfation",
        "GPI-Anchor",
        "Disulfide",
        "Ubiquitination"];

    if (document.getElementById("chk_all").checked){
        achked=[].concat(achk);
        for (id in achk){
            document.getElementById(achk[id]).checked=true;
        }
    }
    else{
        achked=[];
        for (id in achk){
            document.getElementById(achk[id]).checked=false;
        }
    }


}
function selType(){

    var achked=new Array;
    var achk=[
        "Phosphorylation",
        "Methylation",
        "Glycosylation",
        "Acetylation",
        "Hydroxylation",
        "Myristoylation",
        "Amidation",
        "Sulfation",
        "GPI-Anchor",
        "Disulfide",
        "Ubiquitination"];

    for (id in achk){
        if (document.getElementById(achk[id]).checked){
            achked.push(achk[id]);
        }
    }
    if(achked.length==0){
    achked=[].concat(achk);
    }
    
    var  oTable = document.getElementById("tblSort");
    var  oTBody = oTable.tBodies[0];
    var  colDataRows = oTBody.rows;
    //var  aTRs =  new  Array;
    for  (  var  i = 0; i < colDataRows.length; i++) {
        HiddenTr(i, 0);
    }

    for  (  var  i = 0; i < colDataRows.length; i++) {
        if(inArray(achked,oTBody.rows[i].cells[2].firstChild.nodeValue)){
            HiddenTr(i,1);
        }
    }

}

function inArray(ached,onode){

    for (id in ached){
        if(ached[id] == onode){
            return true;
        }
    }
    return false;
}

function HiddenTr(num,display)
{
    var  oTable = document.getElementById("tblSort");
    var  oTBody = oTable.tBodies[0];
    var tempTd=oTBody.getElementsByTagName("tr")[num]
    if(display=="1")
        tempTd.style.display=""
    else
        tempTd.style.display="none"
}
