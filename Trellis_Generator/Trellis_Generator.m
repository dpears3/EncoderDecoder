
g1 = [1 1 1];
g2 = [1 0 1];

g12 = [1 1 1 1];
g22 = [1 1 0 1];
%Example
%trellis = GenerateTrellis(3, g1, g2, 0)
encoded1 = Encoder(3, [1 1 1 0 1 0 0], g1, g2, 0)
encoded2 = Encoder(3, [1 1 0 0 1 1 1 0 1 1], g1, g2, 1)
encoded3 = Encoder(4, [1 1 1 0 1 0 0 0], g12, g22, 0)
encoded4 = Encoder(4, [1 1 1 0 1 0 0 0], g12, g22, 1)
trellis1 = GenerateTrellis(3, g1, g2, 0)
trellis2 = GenerateTrellis(4, g12, g22, 1)
decoded1 = Viterbi(encoded1, 3, trellis1, 0)
%[final_state_temp, Up, Down] = Conv_Encoder(3, g1, g2, 1, [0 0 1] , 0)

% Viterbi Algorithm
% Prints out final result 
function decoded = Viterbi(encoded, K, trellis, selection)
    %Stores path metric
    path = Inf(2^K,length(encoded)/2);
    %Stores branch metric
    branch = zeros(2^K,1);
    temp_path = Inf(2^(K+1));
    temp_best = [];
    best_path = zeros(1, length(encoded)/2);
    % S0-0
    % S0-1
    % S2-0
    % S2-1
    % S1-2
    % S1-3
    % S3-2
    % S3-3
    %0     0     0     0     0     0     0
    % 1     0     0     1     0     1     1
    % 0     0     1     0     0     1     1
    % 1     0     1     1     0     0     0
    % 0     1     0     0     1     1     0
    % 1     1     0     1     1     0     1
    % 0     1     1     0     1     0     1
    % 1     1     1     1     1     1     0
    if selection==0
        %Iterate through encoded bits
        for i=1:(length(encoded)/2)
            if i==1
                %State0-0
                path(1,1) = sum(xor(encoded((2*i-1):2*i), trellis(1, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State0-1
                path(2,1) = sum(xor(encoded((2*i-1):2*i), trellis(2, (length(trellis(1,:))-1):length(trellis(1,:)))));
            elseif i==2
                %State 0-0
                path(1,2) = path(1,1)+sum(xor(encoded((2*i-1):2*i), trellis(1, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 0-1
                path(2,2) = path(1,1)+sum(xor(encoded((2*i-1):2*i), trellis(2, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 1-2
                path(3,2) = path(2,1)+sum(xor(encoded((2*i-1):2*i), trellis(5, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 1-3
                path(4,2) = path(2,1)+sum(xor(encoded((2*i-1):2*i), trellis(6, (length(trellis(1,:))-1):length(trellis(1,:)))));
            elseif i==3
                %State 0
                path(1,3) = path(1,2)+sum(xor(encoded((2*i-1):2*i), trellis(1, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(2,3) = path(1,2)+sum(xor(encoded((2*i-1):2*i), trellis(2, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 1
                path(3,3) = path(2,2)+sum(xor(encoded((2*i-1):2*i), trellis(5, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(4,3) = path(2,2)+sum(xor(encoded((2*i-1):2*i), trellis(6, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 2
                path(5,3) = path(3,2)+sum(xor(encoded((2*i-1):2*i), trellis(3, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(6,3) = path(3,2)+sum(xor(encoded((2*i-1):2*i), trellis(4, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 3
                path(7,3) = path(4,2)+sum(xor(encoded((2*i-1):2*i), trellis(7, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(8,3) = path(4,2)+sum(xor(encoded((2*i-1):2*i), trellis(8, (length(trellis(1,:))-1):length(trellis(1,:)))));
                
                %Prune process
                for k=1:length(path(:,1))
                    if path(k,i) > 3
                        path(k,i) = Inf;
                    end
                end
            else
                %State 0
                path(1,i) = path(1,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(1, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(2,i) = path(1,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(2, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 1
                path(3,i) = path(2,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(5, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(4,i) = path(2,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(6, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 2
                path(5,i) = path(3,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(3, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(6,i) = path(3,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(4, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 3
                path(7,i) = path(4,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(7, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(8,i) = path(4,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(8, (length(trellis(1,:))-1):length(trellis(1,:)))));
                
                path(1,i) = path(5,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(1, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(2,i) = path(5,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(2, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 1
                path(3,i) = path(6,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(5, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(4,i) = path(6,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(6, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 2
                path(5,i) = path(7,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(3, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(6,i) = path(7,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(4, (length(trellis(1,:))-1):length(trellis(1,:)))));
                %State 3
                path(7,i) = path(8,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(7, (length(trellis(1,:))-1):length(trellis(1,:)))));
                path(8,i) = path(8,i-1)+sum(xor(encoded((2*i-1):2*i), trellis(8, (length(trellis(1,:))-1):length(trellis(1,:)))));
                
                %Prune process
                for k=1:length(path(:,1))
                    if path(k,i) > 3
                        path(k,i) = Inf;
                    end
                end
            end
        end
        
        decoded = path;
    elseif selection==1
        
    else
        disp('Wrong selection variable');
    end
end

% Genereate trellis function
% Prints out in order of:
% [Input bit, Initial State, Final State, Output bits(2 bits)]
function trellis = GenerateTrellis(K, g1, g2, selection)
    %test1_output = zeros(2^K,K*2);
    %final_state = [0 0];
    
    BinarySequence = dec2bin(2^(K-1)-1:-1:0)-'0';
    trellis_temp = zeros(2^K, (K-1)*2+3); %Temporary memory to save trellis
    counter = 1;
    for i=length(BinarySequence):-1:1
        in = 0;
        for j=1:2
            [final_state_temp, Up, Down] = Conv_Encoder(K, g1, g2, in, BinarySequence(i,:), selection);
            trellis_temp(counter,:) = [in, BinarySequence(i,:), final_state_temp, Up, Down];
            in = ~in;
            counter = counter+1;
        end
    end
    
    trellis = trellis_temp;
    
    %Plot trellis Diagram
    figure(1);
    for i=1:length(trellis)
        Initial = binaryVectorToDecimal(flip(trellis(i,2:K)));
        Final = binaryVectorToDecimal(flip(trellis(i,(K+1):(K+K-1))));
        if trellis(i,1) == 0
            plot([1,2],[Initial,Final],'--','Color','k')
            out_txt = trellis(i, (length(trellis(1,:))-1):length(trellis(1,:)));
            text(1.5,(Initial+Final)/2,mat2str(out_txt));
        else
            plot([1,2],[Initial,Final],'Color','k')
            out_txt = trellis(i, (length(trellis(1,:))-1):length(trellis(1,:)));
            text(1.5,(Initial+Final)/2,mat2str(out_txt));
        end
        hold on
    end
    title('Trellis Diagram')
    ylabel('States')
    ylim([-1,2^(K-1)])
    hold off
end

%Encoder
% w is the input bits
function encoded = Encoder(K, w, g1, g2, selection)
    %Iterate through input bits
    final_state = zeros(1,K-1);
    counter = 1;
    for i=1:length(w)
        [final_state, encoded(counter), encoded(counter+1), CarryOut] = Conv_Encoder(K, g1, g2, w(i), final_state, selection);
        counter = counter+2;
    end
end

%Convolutional Encoder
%g1 and g2 are connection polynomial
%K is constraint length
%n is an input to shift register
%CarryIn and CarryOut are for systematic recursive encoder
%Left high-Right low
function [final_state, Up, Down, CarryOut] = Conv_Encoder(K, g1, g2, n, init_state, selection)
    %if init_state == Inf
    %    Shift_reg = zeros(1,K);
    %else
    %    Shift_reg = init_state;
    %end
    Shift_reg = init_state;
    if selection == 0 % Feed-Forward encoder
        
        Up = mod(n + sum(and(g1(2:length(g1)),Shift_reg)),2);
        Down = mod(n + sum(and(g2(2:length(g2)),Shift_reg)),2);
        
        %Shift the bits
        for i=length(Shift_reg):-1:2
            Shift_reg(i) = Shift_reg(i-1);
        end
        Shift_reg(1) = and(n, g1(1)); %This is where the input comes in
        final_state = Shift_reg;
        CarryOut = 0;
    elseif selection == 1 %Recursive, g1/g2 encoder
        Up = n;
        %Parity output
        n_temp = Shift_reg(length(Shift_reg)) + n;
        Down = mod(n_temp + sum(and(g1(2:length(g1)),Shift_reg)),2);
        CarryOut = Shift_reg(length(Shift_reg));
        
        %Shift the bits
        for i=length(Shift_reg):-1:2
            Shift_reg(i) = Shift_reg(i-1);
        end
        Shift_reg(1) = mod(n_temp, 2);
        final_state = Shift_reg;
    else
        disp('No selection')
    end
end
