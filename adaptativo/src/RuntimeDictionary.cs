using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Text.RegularExpressions;
public static partial class PortugueseSupport {
 static Dictionary<string,string> known, normalized;
 static readonly Regex indentation=new Regex(@"</?indent(?:=[^>]*)?>",RegexOptions.CultureInvariant);
 static readonly Regex spacing=new Regex(@"\s+",RegexOptions.CultureInvariant);
 static string Canonical(string text){return spacing.Replace(indentation.Replace(text," ")," ").Trim();}
 static string TranslateKnown(string value) {
  if(String.IsNullOrEmpty(value))return value;
  if(known==null){
   var map=new Dictionary<string,string>(StringComparer.Ordinal);
   var aliases=new Dictionary<string,string>(StringComparer.Ordinal);
   var ambiguous=new HashSet<string>(StringComparer.Ordinal);
   using(var stream=typeof(PortugueseSupport).Assembly.GetManifestResourceStream("AeonsEnd.PTBR.Dictionary"))
   using(var reader=new StreamReader(stream,Encoding.UTF8)){
    string line;while((line=reader.ReadLine())!=null){
     if(line.Length==0)continue;string[] p=line.Split('\t');
     string source=Encoding.UTF8.GetString(Convert.FromBase64String(p[0])),target=Encoding.UTF8.GetString(Convert.FromBase64String(p[1]));
     map.Add(source,target);
     string key=Canonical(source),prior;
     if(aliases.TryGetValue(key,out prior) && Canonical(prior)!=Canonical(target))ambiguous.Add(key);
     else aliases[key]=target;
    }
   }
   foreach(string key in ambiguous)aliases.Remove(key);
   normalized=aliases;known=map;
  }
  string translated;if(known.TryGetValue(value,out translated))return translated;
  string trimmed=value.Trim();
  if(trimmed!=value && known.TryGetValue(trimmed,out translated)){
   int start=value.IndexOf(trimmed,StringComparison.Ordinal);
   return value.Substring(0,start)+translated+value.Substring(start+trimmed.Length);
  }
  // Formatting-only variation: every word, number, punctuation mark and other
  // rich-text tag must still match. Ambiguous aliases are deliberately omitted.
  if(normalized.TryGetValue(Canonical(value),out translated))return indentation.Replace(translated,"");
  return value;
 }
}
