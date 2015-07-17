
macro gets(string,n)
{
//get the first substring from the location
//"n" to the end of whole string
    var first;
    var last;
    
    if(n>=strlen(string))
        return nil;
    first=n;
    while(strmid(string,first,first+1)==" ")
    {
        
        first=first+1;
        if(first==strlen(string))
            return nil;
    }
    last=first;
    while(strmid(string,last,last+1)!=" ")
    {
        last=last+1;
        if(last==strlen(string))
            break;
    }
    t=strmid(string,first,last); 
    return t;
}

macro points_to_set()
{
    var     sel_name;  
    var     sel_line;
    var     file_handle;
   
    var     string;
    var     pointer;
    var     linecount;
    var     file_line;//the line that is being disposing in file
    var     record_line_num;//the line_num of pointer recorded in file

    var     fscs_pointer;
    var     flag;
  
    flag = 0;//pointer name don't equal the selected var
 
    cur_wnd = GetCurrentWnd()
    sel_line = GetWndSelLnFirst(cur_wnd)//the first line of seleciont area
    sel_line=sel_line+1;
    cur_buf = GetCurrentBuf()
    sel_name = GetBufSelText(cur_buf)
    //msg "@sel_name@ @sel_line@";

    if(sel_name=="")
    {
        msg "please select a pointer that point to a variable";
        stop;
    }

    //print out steensgaard analysis result 
    file_handle=openbuf("../stgd_pointer.txt");
    if(file_handle==hnil)
    {
        msg "Can't open the file <stgd_pointer.txt>";
        stop;
    }
    
    linecount=GetBufLineCount (file_handle);
    file_line=0;
    while(file_line<linecount)
    {
       
        string=GetBufLine (file_handle, file_line);
        
        if(strlen(string)==0)
        {
             file_line=file_line+1;
             continue;
        }
        first=strmid(string,0,1);
        
        if(AsciiFromChar(first)==AsciiFromChar("["))
            if(flag==1)//the current pointer point to more than one var
            {
                fscs_pointer=cat(fscs_pointer,"或");
                var cur_pos;
                cur_pos=strlen("[   n]");
                points_type=gets(string,cur_pos);
                len_points_type=strlen(points_type);
                cur_pos=cur_pos+len_points_type;
                cur_pos=cur_pos+strlen("    name=");
                fscs_pointer=cat(fscs_pointer,gets(string,cur_pos));
            }
        if(AsciiFromChar(first)!=AsciiFromChar([))
        {
            if(flag == 1)//alreay find
            {
                break;
            }
            if(strlen(string) > strlen("8 p [   1] VAR   name"))
            {
                
                var cur_pos;
                cur_pos = 0;
                record_line_num = gets(string,0);
                len_num=strlen(record_line_num);
                
                cur_pos=cur_pos+len_num; 
                pointer=gets(string,cur_pos+1);
                len_pointer=strlen(pointer);
                
                cur_pos=cur_pos+len_pointer;
                cur_pos=cur_pos+strlen(" [   1] ");
                point_type=gets(string,cur_pos+1);
                len_point_type=strlen(point_type);
                cur_pos=cur_pos+len_point_type;
                
                if(point_type=="VAR")
                {
                    fscs_pointer=gets(string,cur_pos+1);
                    len_points_to_object=strlen(fscs_pointer);
                    fscs_pointer=strmid(fscs_pointer,strlen("name="),len_points_to_object);
                }      
                else//if point_type=="HEAP"
                    fscs_pointer=gets(string,cur_pos+1);
                
                //msg "@pointer@ @record_line_num@";
                if(pointer==sel_name)
                    if(record_line_num==sel_line)
                    {
                        
                        flag=1;
                    }
                
            }
        }       
        file_line=file_line+1;
    }
    closebuf(file_handle);
    
    if(flag==0)
    {
        fscs_pointer = "NULL";
    }

   
    // print out aggresssive pointer analysis result
    file_handle = openbuf("../Agrs_pointer.txt");
    if(file_handle==hnil)
    {
       Msg "can't open the file \"Agrs_pointer.txt\"";
       stop;
    }
    linecount=GetBufLineCount (file_handle);
    file_line=0;
    var    ptf_flag;
    var    len_of_num;
    var    cur_pos;
    var    ptf_pointer_set;
    var    len_of_string;
    ptf_flag = 0;// the pointer points to noting
    while(file_line<linecount)
    {
       
        string=GetBufLine (file_handle, file_line);
        
        if(strlen(string)==0)
        {
             file_line=file_line+1;
             continue;
        }
        record_line_num = gets(string,0);
        
        len_of_num = strlen(record_line_num);
        len_of_string =strlen( string );
        cur_pos = len_of_num; 
        
        if( record_line_num == sel_line)
        {
            ptf_pointer_set=strmid(string,cur_pos+1,len_of_string);
            
            ptf_flag=1;
            break;
        }
        file_line = file_line + 1;
     }
   closebuf(file_handle);
   if(ptf_flag == 0 || ptf_pointer_set == "")
       ptf_pointer_set = "NULL";
   
   Msg "line:@sel_line@ \"@sel_name@\" -> (1):\"@fscs_pointer@\"  (2): \"@ptf_pointer_set@\"";
    
}

