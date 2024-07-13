program ormastime;
uses    SysUtils;
type array25000=array[0..15000] of byte;
var e,e1,e2:array25000;     arrayShowEnable:boolean;
    eDim,counter:word;
    bigData0,bigData1:LongInt;
const spc='              ';   post=' ms --- ';
{$APPTYPE CONSOLE}

procedure arrShow;     var l:byte;       i,j,maxCnt:word;
begin
  if not (arrayShowEnable) then begin exit;end;
  j:=0;
  if  (eDim<256) then maxCnt:=eDim else maxCnt:=255;
        for i:= 0 to maxCnt do
              begin
                inc(j);if (j>27) then begin writeln; j:=0;end;
                                       l:=e[i]; if (l<10)  then write(' ');
                                                if (l<100) then write(' ');
                                       write (' ',l);
              end;
 writeln;
end;
procedure saveResult; var cnt1:word;
begin
      //saving sort result (array 'e') to e2
      for cnt1:= 0 to eDim do e2[cnt1]:= e[cnt1]; end;

procedure diffSearch(a:string);   var noDiff:boolean;   cnt:word;
begin
      noDiff:=true;  writeln('Differencies between ',a,': ');
      for cnt:= 0 to eDim do if (e2[cnt]<>e[cnt]) then begin
      writeln(cnt,'. ',' selsort1: ',e2[cnt],'  bubblesort: ',e[cnt]);noDiff:=false; end;
      if (noDiff) then writeln(spc,spc,spc,'No differencies.');   end;
//time acquisition
function timeAq(b:boolean):LongInt;
        var hh, mm, ss, ss100: Word;   date0: TDateTime;  bigData:LongInt;
        const cln=':';
begin
        date0 := Now;           DecodeTime(date0, hh, mm, ss, ss100);
        bigData:=ss*1000+ss100;
        if (b) then
                   writeln( '--- timeStamp ',bigData,' ---');
        timeAq:= bigData;
end;

// ----------------  selection sort one direction ----------------------
// 25000 items 140 ms sort time
procedure selSort1;             var i,j,index,eDimMns,auxVal:word;
                                    swapEnable:boolean;
begin
eDimMns:=eDim-1;
for i:=0 to eDimMns do
     begin
        auxVal:=e[i];   index:=i;   swapEnable:= false;
        for j:=i+1 to eDim do if (e[j]>auxVal) then begin
                                                        auxVal:=e[j]; index:=j;
                                                        swapEnable:= true;
                                                    end;
        if (swapEnable) then begin
                                   auxVal:=e[i];  e[i]:=e[index];  e[index]:=auxVal;
                               end;

     end;
end;
// ----------------  selection sort two directions ----------------------
// 25000 items --- ms sort time
procedure selSort2;             var i,s,f,maxIdx,minIdx:word;
                                    maxVal,minVal,swapMode:byte;
                                    noCorner:boolean;
begin
        s:=0; f:=eDim;
        repeat
                maxVal:=e[s]; minVal:=e[f];
                maxIdx:=s;    minIdx:=f;
                for i:=s to f do begin
                                        if (e[i]>maxVal) then begin maxVal:=e[i];maxIdx:=i; end;
                                        if (e[i]<minVal) then begin minVal:=e[i];minIdx:=i; end;
                end;
             // logic block
               noCorner:=true;  swapMode:=0;
             if not (((maxIdx=s) and (minIdx=f)) or ((maxIdx=f) and (minIdx=s))) then begin
                if (maxIdx=s) then begin noCorner:=false; swapMode:=1;
                end;
                if (maxIdx=f) then begin noCorner:=false; e[minIdx]:=e[s];
                end;
                if (minIdx=f) then begin noCorner:=false; swapMode:=2;
                end;
                if (minIdx=s) then begin noCorner:=false; e[maxIdx]:=e[f];
                end;
                if (noCorner) then begin
                                         e[maxIdx]:=e[s];
                                         e[minIdx]:=e[f];      end;
             end;
           case swapMode of 1: begin e[minIdx]:=e[f];  e[f]:=minVal;  end;
                            2: begin e[maxIdx]:=e[s];  e[s]:=maxVal;  end;
           else begin
                e[s]:=maxVal; e[f]:=minVal; end;
           end;
        inc(s);dec(f);
        until (s>f-1);
end;
// ----------------  bubble sort  ----------------------
// 25000 items 360 ms sort time
procedure bubbleSort;    var tmp:byte; i,j:word;
begin
     for i:=0 to eDim-1 do
           // В конце уже отсортированные элементы, их можно исключить.
          for j:=0 to eDim-i-1 do begin
               // Сравнение элементов: если пара элементов не отсортирована, меняем их местами.
               if (e[j]<e[j+1]) then begin
                        tmp:=e[j];      e[j]:=e[j+1];    e[j+1]:=tmp;
               end;
          end;
end;
// ----------------  Insertion sort ----------------------
procedure insSort1;
       var key:byte;    i,j:word;
begin
    for i:=1 to eDim do
      begin
           key:=e[i]; j:=i;
             while (e[j-1]<key) do
                   begin
                        e[j]:=e[j-1];
                        dec(j);
                        if (j<1) then break;
                   end;
           e[j]:=key;
      end;
end;
// --- main ---
begin           randomize;            eDim:= length(e)-1;
writeln('Sort arrays. v.4.0.1');
writeln(eDim+1,' bytes sorting time:'); writeln;
                if (eDim>255) then arrayShowEnable:=false else arrayShowEnable:=true;
                for counter:= 0 to eDim do e1[counter]:= random(256);
//array filling for Insert Sort
                        for counter:= 0 to eDim do e[counter]:= e1[counter];
                           arrShow;
//getting first timestamp
  bigData0:=timeAq(false);
                           insSort1;
//getting last timestamp
  bigData1:=timeAq(false); arrShow;
                        writeln(spc,'Insert Sort1 ',bigData1-bigData0,post); writeln;
                        //saving sort result (array 'e') to e2 for diff b/w selsort1 and bubble sort
                        saveResult;
//array filling for selection Sort1
                        for counter:= 0 to eDim do e[counter]:= e1[counter];
//getting first timestamp
  bigData0:=timeAq(false);
                           selSort1;
//getting last timestamp
  bigData1:=timeAq(false); arrShow;
                        writeln(spc,'selection Sort1 ',bigData1-bigData0,post); writeln;


//array filling for selection Sort2
                           for counter:= 0 to eDim do e[counter]:= e1[counter];
//getting first timestamp
  bigData0:=timeAq(false);
                           selSort2;
//getting last timestamp
  bigData1:=timeAq(false); arrShow;
                           writeln(spc,'selection Sort2 ',bigData1-bigData0,post); writeln;

//array filling for bubble Sort
                        for counter:= 0 to eDim do e[counter]:= e1[counter];
//getting first timestamp
  bigData0:=timeAq(false);
                          bubbleSort;
//getting last timestamp
  bigData1:=timeAq(false); arrShow;
                           writeln(spc,'bubble Sort ',bigData1-bigData0,post );
                           diffSearch('Inssort1 and bubble sort');
writeln('======================================================================================');
//array filling for selection Sort1
                        for counter:= 0 to eDim do e[counter]:= e1[counter];
                           arrShow;
//getting first timestamp
  bigData0:=timeAq(false);
                           selSort1;
//getting last timestamp
  bigData1:=timeAq(false); arrShow;
                        writeln(spc,'selection Sort1 ',bigData1-bigData0,post); writeln;

//array filling for selection Sort2
                           for counter:= 0 to eDim do e[counter]:= e1[counter];
//getting first timestamp
  bigData0:=timeAq(false);
                           selSort2;
//getting last timestamp
  bigData1:=timeAq(false); arrShow;
                           writeln(spc,'selection Sort2 ',bigData1-bigData0,post); writeln;
                           //saving sort result (array 'e') to e2 for diff b/w selsort2 and bubble sort
                        saveResult;
//array filling for bubble Sort
                        for counter:= 0 to eDim do e[counter]:= e1[counter];
//getting first timestamp
  bigData0:=timeAq(false);
                          bubbleSort;
//getting last timestamp
  bigData1:=timeAq(false); arrShow;
                           writeln(spc,'bubble Sort ',bigData1-bigData0,post ); writeln;
// differencies search
                        diffSearch('selsort2 and bubble sort');
  writeln('enter to terminate process');readln;
end.
