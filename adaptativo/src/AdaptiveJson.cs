using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
public static class AdaptiveJson {
 public static Dictionary<string,string> Map=new Dictionary<string,string>(StringComparer.Ordinal);
 public static HashSet<string> Keys=new HashSet<string>(StringComparer.Ordinal);
 public static int Changes;
 public static void Load(string map,string keys){Map.Clear();Keys.Clear();foreach(string line in File.ReadAllLines(map,Encoding.UTF8)){if(line.Length==0)continue;string[] p=line.Split('\t');Map.Add(Encoding.UTF8.GetString(Convert.FromBase64String(p[0])),Encoding.UTF8.GetString(Convert.FromBase64String(p[1])));}foreach(string k in File.ReadAllLines(keys))Keys.Add(k);Changes=0;}
 public static string Translate(string s){return new Parser(s).Translate();}
 sealed class Parser {
  readonly string text; int p; readonly List<Edit> edits=new List<Edit>();
  sealed class Edit {public int Start,Length;public string Value;}
  public Parser(string s){text=s;}
  void White(){while(p<text.Length){if(char.IsWhiteSpace(text[p])||text[p]=='\ufeff'){p++;continue;}if(p+1<text.Length&&text[p]=='/'&&text[p+1]=='/'){while(p<text.Length&&text[p]!='\n')p++;continue;}if(p+1<text.Length&&text[p]=='/'&&text[p+1]=='*'){int end=text.IndexOf("*/",p+2,StringComparison.Ordinal);if(end<0)throw new InvalidDataException("JSON comment");p=end+2;continue;}break;}}
  void Expect(char c){White();if(p>=text.Length||text[p++]!=c)throw new InvalidDataException("Unexpected JSON structure");}
  string String(){char quote=text[p++];var b=new StringBuilder();bool closed=false;while(p<text.Length){char c=text[p++];if(c==quote){closed=true;break;}if(c!='\\'){b.Append(c);continue;}if(p>=text.Length)break;c=text[p++];switch(c){case 'n':b.Append('\n');break;case 'r':b.Append('\r');break;case 't':b.Append('\t');break;case 'b':b.Append('\b');break;case 'f':b.Append('\f');break;case 'v':b.Append('\v');break;case '0':b.Append('\0');break;case '\n':break;case '\r':if(p<text.Length&&text[p]=='\n')p++;break;case 'u':case 'x':int n=c=='u'?4:2;if(p+n>text.Length)throw new InvalidDataException("JSON escape");b.Append((char)Convert.ToInt32(text.Substring(p,n),16));p+=n;break;default:b.Append(c);break;}}if(!closed)throw new InvalidDataException("JSON string");return b.ToString();}
  string Key(){White();if(p>=text.Length)throw new InvalidDataException("Missing key");if(text[p]=='"'||text[p]=='\'')return String();int start=p;while(p<text.Length&&(char.IsLetterOrDigit(text[p])||text[p]=='_'||text[p]=='$'))p++;if(p==start)throw new InvalidDataException("Invalid key");return text.Substring(start,p-start);}
  static string Quote(string value){var b=new StringBuilder("\"");foreach(char c in value){switch(c){case '"':b.Append("\\\"");break;case '\\':b.Append("\\\\");break;case '\n':b.Append("\\n");break;case '\r':b.Append("\\r");break;case '\t':b.Append("\\t");break;default:if(c<32)b.Append("\\u"+((int)c).ToString("x4"));else b.Append(c);break;}}return b.Append('"').ToString();}
  void Value(bool display,string key,int depth){if(depth>128)throw new InvalidDataException("JSON depth");White();if(p>=text.Length)throw new InvalidDataException("Missing value");char c=text[p];if(c=='{'){p++;White();if(p<text.Length&&text[p]=='}'){p++;return;}while(true){string k=Key();Expect(':');Value(Keys.Contains(k),k,depth+1);White();if(p<text.Length&&text[p]=='}'){p++;break;}Expect(',');White();if(p<text.Length&&text[p]=='}'){p++;break;}}}else if(c=='['){p++;White();if(p<text.Length&&text[p]==']'){p++;return;}while(true){Value(display,key,depth+1);White();if(p<text.Length&&text[p]==']'){p++;break;}Expect(',');White();if(p<text.Length&&text[p]==']'){p++;break;}}}else if(c=='"'||c=='\''){int start=p;string s=String(),v;if((display||(key=="speaker"&&s.Contains(",")))&&Map.TryGetValue(s,out v)&&v!=s){edits.Add(new Edit{Start=start,Length=p-start,Value=Quote(v)});Changes++;}}else{int start=p;while(p<text.Length&&!char.IsWhiteSpace(text[p])&&text[p]!=','&&text[p]!=']'&&text[p]!='}'&&text[p]!='/')p++;if(start==p)throw new InvalidDataException("Invalid value");}}
  public string Translate(){Value(false,"",0);White();if(p!=text.Length)throw new InvalidDataException("Trailing JSON content");var b=new StringBuilder(text);for(int i=edits.Count-1;i>=0;i--){var e=edits[i];b.Remove(e.Start,e.Length);b.Insert(e.Start,e.Value);}return b.ToString();}
 }
}
