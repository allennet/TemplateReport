using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Script.Serialization;

namespace ENLReport_WordDemo.Models
{
    public class EditorHtmlConverter
    { 
        /// <summary>
        /// 填充表单内容,该方法可以重写
        /// </summary>
        /// <param name="dataJson">数据JSON</param>
        /// <param name="htmlStr">表单内容</param>
        /// <returns></returns>
        public virtual string ConvertHtml(string dataJson, string htmlStr)
        {
            try
            {
                string resultHtml = string.Empty;
                //转换数据
                dynamic data = DataDeserialize(dataJson);
                //填充普通字段
                resultHtml = ConvertCommonField(data, htmlStr);
                //填充表格字段
                resultHtml = ConvertTableField(data, resultHtml);
                return resultHtml;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        /// <summary>
        /// 填充普通字段({#C_说明_XXX#})
        /// </summary>
        /// <param name="data">数据</param>
        /// <param name="htmlStr">表单内容</param>
        /// <returns>返回处理完的内容</returns>
        public virtual string ConvertCommonField(Dictionary<string, dynamic> data, string htmlStr)
        {
            ContentHtmlRegx regx = new ContentHtmlRegx();
            MatchCollection collection = regx.GetCommonFieldMatch(htmlStr);
            if (collection == null || collection.Count == 0)
                return htmlStr;
            foreach (Match mc in collection)
            {
                string fieldHtml = mc.Groups[0].Value.ToString();
                string tempFieldHtml = fieldHtml;
                string[] fieldArray = fieldHtml.Replace("{#", "").Replace("#}", "").Split('_');
                if (fieldArray.Length >= 3 && fieldArray[0].ToUpper() == "C")
                {
                    if (data.Keys.Contains(fieldArray[2]))
                        htmlStr = htmlStr.Replace(tempFieldHtml, data["" + fieldArray[2] + ""]);
                }
            }
            return htmlStr;
        }

        /// <summary>
        /// 填充表格字段[#T_说明_XXX_YYY#]
        /// </summary>
        /// <param name="data"></param>
        /// <param name="htmlStr"></param>
        /// <returns></returns>
        public virtual string ConvertTableField(Dictionary<string, dynamic> data, string htmlStr)
        {
            ContentHtmlRegx regx = new ContentHtmlRegx();
            MatchCollection tableCollection = regx.GetTableMatch(htmlStr);
            if (tableCollection == null || tableCollection.Count == 0)
                return htmlStr;
            string resultHtmlStr = htmlStr;
            foreach (Match tableMC in tableCollection)
            {
                string tableHtml = tableMC.Groups[0].Value.ToString();
                MatchCollection tableFieldCollection = regx.GetTableFieldMatch(tableHtml);
                if (tableFieldCollection == null || tableFieldCollection.Count == 0)
                    continue;
                MatchCollection trCollection = regx.GetTableTrMatch(tableHtml);
                if (trCollection == null || trCollection.Count == 0)
                    continue;
                string trHtml = trCollection[0].Groups[0].Value.ToString();
                string newTableHtml = trHtml;
                string pField = "";
                //处理表头
                foreach (Match tableFieldMC in tableFieldCollection)
                {
                    string tableFieldHtml = tableFieldMC.Groups[0].Value.ToString();
                    string[] fieldArray = tableFieldHtml.Replace("[#", "").Replace("#]", "").Split('_');
                    if (string.IsNullOrEmpty(pField))
                        pField = fieldArray[2];
                    else
                    {
                        //不支持表格中出现不同的父节点
                        if (pField != fieldArray[2])
                        {
                            pField = string.Empty;
                            break;
                        }
                    }
                    if (fieldArray.Length >= 2 && fieldArray[0].ToUpper() == "T")
                    {
                        newTableHtml = newTableHtml.Replace(tableFieldHtml, fieldArray[1]);
                    }
                }
                //判断是否含有表格的父节点
                if (string.IsNullOrEmpty(pField) == true || data.Keys.Contains(pField) == false)
                    continue;
                //处理表格内容
                dynamic tableData = data["" + pField + ""];
                if (tableData == null)
                    continue;
                string tempTrStr = string.Empty;
                string tableTrStr = string.Empty;
                foreach (var tempData in tableData)
                {
                    tempTrStr = trHtml;
                    foreach (Match tableFieldMC in tableFieldCollection)
                    {
                        string tableFieldHtml = tableFieldMC.Groups[0].Value.ToString();
                        string[] fieldArray = tableFieldHtml.Replace("[#", "").Replace("#]", "").Split('_');
                        if (fieldArray.Length >= 3 && fieldArray[0].ToUpper() == "T")
                        {
                            Dictionary<string, dynamic> dicData = tempData as Dictionary<string, dynamic>;
                            if (dicData.Keys.Contains(fieldArray[3]))
                                tempTrStr = tempTrStr.Replace(tableFieldHtml, tempData["" + fieldArray[3] + ""]);
                        }
                    }
                    tableTrStr += tempTrStr;
                }
                newTableHtml += tableTrStr;
                resultHtmlStr = htmlStr.Replace(trHtml, newTableHtml);
            }
            return resultHtmlStr;
        }

        /// <summary>
        /// 反序列化
        /// </summary>
        /// <param name="dataJson">数据Json字符串</param>
        /// <returns></returns>
        private Dictionary<string, dynamic> DataDeserialize(string dataJson)
        {
            try
            {
                JavaScriptSerializer js = new JavaScriptSerializer();
                Dictionary<string, dynamic> entity = js.Deserialize<Dictionary<string, dynamic>>(dataJson); //反序列化  
                return entity;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }
    }
}