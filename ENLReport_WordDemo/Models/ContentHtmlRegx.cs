using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;

namespace ENLReport_WordDemo.Models
{
    /// <summary>
    /// 获取Html中相应标签信息
    /// </summary>
    public class ContentHtmlRegx
    {
        /// <summary>
        /// 公共字段标签正则表达式，用于直接字段内容直接替换的标签
        /// </summary>
        private string commonFieldRegx = @"\{#C_[^_]{1,}_[0-9a-zA-Z]{1,}\#\}"; //@"\{#(.*?)\#\}";;
        /// <summary>
        /// 表格标签正则表达式
        /// </summary>
        private string tableRegx = @"<table.*?>[\s\S]*?<\/table>";
        /// <summary>
        /// 表格字段标签正在表达式
        /// </summary>
        private string tableFieldRegx = @"\[#T_[^_]{1,}_[0-9a-zA-Z]{1,}_[0-9a-zA-Z]{1,}\#\]";//@"\[#(.*?)\#\]"

        /// <summary>
        /// Tr标签正则表达式
        /// </summary>
        private string trRegx = @"<tr.*?>[\s\S]*?<\/tr>";

        /// <summary>
        /// 获取匹配的集合
        /// </summary>
        /// <param name="source">源数据</param>
        /// <param name="matchRegx">匹配正则</param>
        /// <returns></returns>
        public MatchCollection GetMatch(string source, string matchRegx)
        {
            if (string.IsNullOrEmpty(source.Trim()) || string.IsNullOrEmpty(matchRegx.Trim()))
                return null;
            MatchCollection collections = Regex.Matches(source, matchRegx, RegexOptions.IgnoreCase);
            if (collections == null || collections.Count == 0)
                return null;
            return collections;
        }

        /// <summary>
        /// 获取公共字段
        /// </summary>
        /// <param name="source">源数据</param>
        /// <returns></returns>
        public MatchCollection GetCommonFieldMatch(string source)
        {
            return GetMatch(source, commonFieldRegx);
        }

        /// <summary>
        /// 获取表格
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public MatchCollection GetTableMatch(string source)
        {
            return GetMatch(source, tableRegx);
        }

        /// <summary>
        /// 获取表格字段
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public MatchCollection GetTableFieldMatch(string source)
        {
            return GetMatch(source, tableFieldRegx);
        }

        /// <summary>
        /// 获取表格字段
        /// </summary>
        /// <param name="source"></param>
        /// <returns></returns>
        public MatchCollection GetTableTrMatch(string source)
        {
            return GetMatch(source, trRegx);
        }

    }
}