function testTcpipCallbackFunc(varargin)
    info=varargin{2};
    con=varargin{1};
    switch(info.Type)
        case 'BytesAvailable'
            if(con.BytesAvailable>0)
                bytes=fscanf(con,'%c',con.BytesAvailable);
                fprintf(char(bytes));
            end
    end
end

