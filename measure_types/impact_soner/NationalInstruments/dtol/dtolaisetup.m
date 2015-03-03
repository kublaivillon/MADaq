function ai=dtolaisetup(XLSetFile)
%DTOLAISETUP: Sets up the Analog Inputs of the DataTranslation unit (dtol)

%See also: DEMOAI_CHANNEL


%%                                   Do settings either by table or default
try;                                                          % Excel table
  [num,txt,raw]=xlsread(XLSetFile,'Settings');
  SampleRate=raw{4,3};        % Sample Rate is in (3,3) cell of spreadsheet
  Ch.Type=raw(6:9,4);
  Ch.Coupl=raw(6:9,5);
  Ch.SN=raw(6:9,3);
  [num,txt,raw]=xlsread(XLSetFile,'Calibration');
  Ch.SNos=raw(4:26,5);
  Ch.cals=raw(4:26,7);
catch;                                                        % Default
  SampleRate=51200;
  Ch.Type={'Volt','Volt','Volt','Volt'}';
end

Nch=length(Ch.Type);


%%                                Stop any running data acquisition objects
try,stop(daqfind);catch,end

%%                        Create an analog input object for the dtol device
ws=warning;warning('Off');                  % Shut off warnings for a while
ai = analoginput('dtol');
warning(ws);

%%                                                       Set Buffering Mode
set(ai,'BufferingMode','Auto');

%%                                                        Set sampling rate
ai.SampleRate=SampleRate;

ai.SamplesPerTrigger=40000;

%%                                                           Add 4 channels
addchannel(ai,[0:3],[1:4]);      % HWchannels 0-3 associated to indices 1-4

%%                                         Set up the channel coupling mode
for I=1:Nch
   if strcmp(lower(Ch.Coupl(I)),'AC')
     ai.Channel(I).Coupling='AC';
   else
     ai.Channel(I).Coupling='DC';
   end
 end  

%% Set up channel InputRange to allow for more than 10V
% for I=1:4
%   set(ai.Channel(I),'InputRange',[-100 100])
% end

%%                                           Set up the channels to be IEPE
 for I=1:Nch
   if strcmp(lower(Ch.Type(I)),'iepe')
     ai.Channel(I).ExcitationCurrentSource='Internal';  
   end
 end  

%%                                           Set up the channel calibration
 for I=1:Nch
   Navail=length(Ch.SNos);
   for II=1:Navail
       if all(Ch.SNos{II}==Ch.SN{I})
           Userdata.cal(I)=Ch.cals{II};
       end    
   end
 end
 set(ai,'User',Userdata);% Put calibration data as User data in ai
 
 