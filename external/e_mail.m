function e_mail(outgoing, server, username, password, subject, msg, attach)

% Utilize MATLAB's sendmail command to send an email
% based on Mathworks link: http://www.mathworks.com/support/solutions/en/data/1-3PRRDV/
% 
% outgoing - the recepient emall address (i.e. 'billybob@gmail.com')
% server - email client being used (i.e. 'gmail', 'yahoo', 'matlabgeeks')
%   Modify lines 38 and add server information in switch statement (lines
%   40-54) for personal email accounts.
% username - your username on the client (i.e. 'vlugade')
% password - your cleartext password on client (i.e. 'password')
% subject - subject line of your email (i.e. 'Free Spam Inside!')
% msg - message content of email (i.e. {'Hello billybob', 'Click this for
%   free stuff'}
% attach - locaton of any attachments you'd like to send

% check number of input arguments
% only the recepient, server, username and password are required.
error(nargchk(4,7,nargin,'struct'));
if (nargin < 7) 
    attach = [];
end
if (nargin < 6)
    msg = '';
end
if nargin < 5
    subject = '';
end
% Warning, if all of attach, msg and subject are missing, the email will
% probably end up in a spam folder, as there is no content.


% set up properties for email server
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
% can change this to port 25, 587, 995 based on server properties
props.setProperty('mail.smtp.socketFactory.port','465');

switch server
    % add in different cases based on server settings
    case 'gmail'
        id = [username,'@gmail.com'];
        setpref('Internet','SMTP_Server','smtp.gmail.com');
    case 'yahoo'
        id = [username,'@yahoo.com'];
        setpref('Internet','SMTP_Server','smtp.mail.yahoo.com');
    case 'matlabgeeks'
        id = [username, '@matlabgeeks.com'];
        setpref('Internet','SMTP_Server','smtp.ipage.matlabgeeks.com');
    otherwise
        id = [username,'@',server,'.com'];
        setpref('Internet','SMTP_Server',['smtp.mail.',server,'.com']);
end

setpref('Internet','E_mail',id);
setpref('Internet','SMTP_Username',id);
setpref('Internet','SMTP_Password',password);

% send the email

sendmail(outgoing,subject,msg,attach)