clc,clear all, close all



% Grafik
    
    [bild, ~ , bild_alpha] = imread('vindturbin.png');
    
    [h, w, ~] = size(bild);
    max_dim = max(h, w);
    padded_img = uint8(zeros(max_dim, max_dim, 3));
    padded_alpha = zeros(max_dim, max_dim);
    
    row_offset = floor((max_dim - h) / 2) + 1;
    col_offset = floor((max_dim - w) / 2) + 1;
    padded_img(row_offset:(row_offset + h - 1), col_offset:(col_offset + w - 1), :) = bild;
    padded_alpha(row_offset:(row_offset + h - 1), col_offset:(col_offset + w - 1)) = bild_alpha;
    
    turbin_array = cell(1, numel(120));
    turbin_bild_data = cell(1, numel(120));
    
    turbin_array{1} = padded_img;
    turbin_bild_data{1} = padded_alpha;
    
    dpf = 3;
    for i=2:1:360/dpf
        turbin_array{i} = imrotate(padded_img,i*dpf,'bilinear', 'crop');
        turbin_bild_data{i} = imrotate(padded_alpha,i*dpf,'bilinear', 'crop');
    end
    

    [bild, ~ , bild_alpha] = imread('snabb_turbin.png');
    
    [h, w, ~] = size(bild);
    max_dim = max(h, w);
    padded_img = uint8(zeros(max_dim, max_dim, 3));
    padded_alpha = zeros(max_dim, max_dim);
    
    row_offset = floor((max_dim - h) / 2) + 1;
    col_offset = floor((max_dim - w) / 2) + 1;
    padded_img(row_offset:(row_offset + h - 1), col_offset:(col_offset + w - 1), :) = bild;
    padded_alpha(row_offset:(row_offset + h - 1), col_offset:(col_offset + w - 1)) = bild_alpha;
    
    snabb_turbin_array = cell(1, numel(120));
    snabb_turbin_bild_data = cell(1, numel(120));
    
    snabb_turbin_array{1} = padded_img;
    snabb_turbin_bild_data{1} = padded_alpha;
    
    dpf2 = 15;
    for i=2:1:360/dpf2
        snabb_turbin_array{i} = imrotate(padded_img,i*dpf2,'bilinear', 'crop');
        snabb_turbin_bild_data{i} = imrotate(padded_alpha,i*dpf2,'bilinear', 'crop');
    end


    bg_bild = imread('bakgrund.png');
    
    [stolpe,~,stolpe_alpha] = imread('stolpe.png');
    
    folder = 'storm_animation';
    imageFiles = dir(fullfile(folder, '*.png'));
    storm_Array = cell(1, numel(imageFiles));
    for i = 1:numel(imageFiles)
        imagePath = fullfile(folder, imageFiles(i).name);
        img = imread(imagePath);
        storm_Array{i} = img;
    end
    folder = 'vindturbin_explosion';
    imageFiles = dir(fullfile(folder, '*.jpg'));
    fail_Array = cell(1, numel(imageFiles));
    for i = 1:numel(imageFiles)
        imagePath = fullfile(folder, imageFiles(i).name);    
        img = imread(imagePath);
        fail_Array{i} = img;
    end
    folder = 'smoke_animation';
    imageFiles = dir(fullfile(folder, '*.jpg'));
    smoke_Array = cell(1, numel(imageFiles));
    smoke_alpha_Array = cell(1, numel(imageFiles));
    for i = 1:numel(imageFiles)
        imagePath = fullfile(folder, imageFiles(i).name);    
        img = imread(imagePath);
        if size(img,3) == 1
            img = repmat(img, [1, 1, 3]);
        end 
        smoke_Array{i} = img;
       
        alpha_channel = ones(size(img, 1), size(img, 2));
        white_pixels = (img(:,:,1) > 230) & (img(:,:,2) > 230) & (img(:,:,3) > 230);
        alpha_channel(white_pixels) = 0;

        smoke_alpha_Array{i} = alpha_channel;
    end



% GUI - element
    main_figure = figure;
    main_figure.Position = [100,50,0.7*[1920,1080]];
    
    bxy = [900,730];
    broms_label = uicontrol(main_figure, 'Style', 'text', ...
                                    'String', sprintf('Bromskraft (MN): 0.00'), ...
                                    'Position', [bxy, 300, 30], 'FontSize',12);
    
    broms_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 4, ...
                       'Value', 0, 'Position', [bxy-[0,20], 300, 20] ...
                       );
    vxy = [20,730];
    vind_label = uicontrol(main_figure, 'Style', 'text', ...
                                    'String', sprintf('Vindstyrka (m/s): 0.00'), ...
                                    'Position', [vxy, 300, 30], 'FontSize',12);
    
    vind_slider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 40, ...
                       'Value', 10, 'Position', [vxy-[0,20], 300, 20] ...
                       );
    vind_slider_value = 10;

    Parkerings_broms_knapp = uicontrol(main_figure, "Style","togglebutton", ...
                                    "Position",[bxy+[310,-20],150,40], ...
                                    "String",'Parkeringbroms','FontSize',12, ...
                                    "BackgroundColor",[1,1,1], ...
                                    'Callback',@Parkeringsbroms);
    info_label = uicontrol(main_figure, 'Style', 'text', ...
                                    'String', sprintf(''), ...
                                    'Position', [vxy+[0,-130], 300, 70], 'FontSize',14,'BackgroundColor','white');

    omega_label = uicontrol(main_figure, 'Style', 'text', ...
                                    'String', sprintf('ω'), ...
                                    'Position', [vxy+[0,-170], 300, 30], 'FontSize',12,'FontWeight','bold');


% Grafer
    
    % bromsmoment
    ax3 = axes('Position', [0.55, 0.58, 0.19, 0.12]);
    ax32 = axes('Position', [0.76, 0.58, 0.19, 0.12]);
    % temp
    ax2 = axes('Position', [0.55, 0.38, 0.19, 0.12]);
    % friktion 
    ax4 = axes('Position', [0.76, 0.38, 0.19, 0.12]);
    % vind
    ax5 = axes('Position', [0.05, 0.05, 0.90, 0.25]);
    % lamba
    ax11 = axes('Position', [0.025, 0.55 0.19, 0.12]);
    % cp 
    ax12 = axes('Position', [0.025, 0.38, 0.19, 0.12]);



    % animering
    % bg
    bildxy = [0.25,0.35];
    ax6 = axes(main_figure,"Position",[bildxy,0.26,0.64]);
    % stolpe
    ax7 = axes(main_figure,"Position",[bildxy,0.26,0.64]); 
    % smoke
    ax10 = axes(main_figure,"Position",[bildxy + [0.023,0.382],0.2,0.356]);    
    % turbin
    ax9 = axes(main_figure,"Position",[bildxy + [0.023,0.242],0.2,0.356]); 
    ax8 = axes(main_figure,"Position",[bildxy + [0.023,0.242],0.2,0.356]);    

    ax1 = axes('Position', [0.55, 0.75, 0.4, 0.12]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% HÄR BÖRJAR KODEN

% Parametrar
    dt = 0.5; % s tidsteg
    simulation_tid = 500; % s simulationsstid

% Broms - parameterar
    F_broms = 0; % N bromskraft
    bromsskiva_radie = 0.5; % m (effektiv radie skivbroms)
    bromsskiva_densitet = 7850; % kg / m^3
    bromsskiva_area = bromsskiva_radie^2*pi; % m^2 
    bromsskiva_tjocklek = 0.05; % m
    bromsskiva_massa = bromsskiva_area * bromsskiva_tjocklek * bromsskiva_densitet; % kg 
    
    spec_varme_kap = 420; % J/kg*K (specific värme kapacitet för bromsskivans material)
    konvektion_koefficent = 100; % W/m^2*K (värmeledningskoefficient / convective heat coefficient)
    start_temp = 20; % C (start temp)
    omgivning_temp = 20; % C (omgivnings temp)
    gear_box_ratio = 60;


% Vindkraftverkets specs
    blad_lngd = 50; % Blade length (m)
    blad_massa = 0.22 * blad_lngd *10^3;
    I_blad = 1/3 * blad_massa * blad_lngd^2 *0.5;
    I = 3*I_blad;
    svept_Area = pi * blad_lngd^2;
    luftdensitet = 1.225; % kg / m^3
    turbin_friktion = 1.1*10^7;
    turbolens = 0.2; % variationen i vindhastighet per tidsteg
    
    % skapar uppskattade effekt-coefficent-modeller
        Cp0 = [0.1, 0.15, 0.25, 0.37, 0.42 , 0.45, 0.4 0.3, 0.21 , 0.15 ];
        CP = interp1( 1:1:numel(Cp0) , Cp0, linspace( 1, numel(Cp0), numel(Cp0)*10 ), 'linear'); %       ..-*¨¨¨-.
    
    % funktion för Cp
        Cp_kurva = @(lambda) diskret_funktion(CP,lambda,10,0.1);
    % funktion för vindkraftseffekt-ekvationen ( Effekt = RörelseEnergi * flöde * Cp )  
        turbin_effekt = @(v,Cp) 0.5 .* luftdensitet .* Cp .* svept_Area .* v.^3;


% Intitierar vektorer med fysikaliska data
    tid = 0:dt:simulation_tid;  
    broms_moment = zeros(1, length(tid));
    temperatur = zeros(1, length(tid));
    heat_map = zeros(100, 1);
    Ang_momentum = zeros(size(tid));
    w = zeros(size(tid));
    vind_hastighet = zeros(size(tid));
    vind_Effekt = zeros(size(tid));
    vind_moment = zeros(size(tid));
    total_moment = zeros(size(tid));
    friktionstal = zeros(size(tid));
    TSR_vec = zeros(size(tid));
    Cp_vec = zeros(size(tid));


% begynnelsevärden
    vind_hastighet(1) = 10;
    Tip_speed_ratio = 7;
    w(1) = vind_hastighet(1) * 1 / blad_lngd;
    Cp = Cp_kurva(Tip_speed_ratio);
    Ang_momentum(1) = I * w(1); 
    friktionstal(1) = 0.3; 
    temperatur(1) = start_temp;
    theta = 0;
    vind_Effekt(1) = turbin_effekt(vind_hastighet(1),Cp);
    vind_moment(1) = blad_lngd * vind_Effekt(1) / vind_hastighet(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN LOOP
for i = 2:length(tid)

% Vind
    vind_hastighet(i) = vind_hastighet(i-1) + turbolens * sqrt(dt) * randn ;
    if vind_slider_value ~= vind_slider.Value
        vind_slider_value = vind_slider.Value;
        vind_hastighet(i) = vind_slider_value;
    end
    Tip_speed_ratio = TSR( vind_hastighet(i-1), w(i-1), blad_lngd);
    Cp = Cp_kurva(Tip_speed_ratio);
    TSR_vec(i) = Tip_speed_ratio;
    Cp_vec(i) = Cp;

    vind_Effekt(i) = 0.5 * luftdensitet * Cp * svept_Area * vind_hastighet(i)^3;
    %vind_moment(i) = blad_lngd * vind_Effekt(i) / vind_hastighet(i);
    vind_moment(i) = 0.5 * luftdensitet * Cp * svept_Area * vind_hastighet(i)^2 * blad_lngd;

% bromsen

    F_broms = 10^6 * get(broms_slider, 'Value') ;

    % beräknar μ för nuvarande temperatur
    friktionstal(i) = my(temperatur(i-1)) ;
        if w(i-1)==0
            % statisk friktion
            friktionstal(i) = friktionstal(i) * 1.55;
        end


    % Beräknar bromsmomentet
    broms_moment(i) = friktionstal(i) * F_broms * bromsskiva_radie  ;
    % Begränsar bromsmomentet så det inte kan överstiga vindmomentet + motverkande riktining (bromsmoment är reaktivt)
    broms_moment(i) = min( abs(broms_moment(i)) , abs( vind_moment(i) ) ) *-1*sign(vind_moment(i));

% Bromsens temperatur

    % Värmeutveckling enligt E = ΔΤ * m * C
    heat_generated = abs(broms_moment(i))  * (abs(w(i-1)) * dt) / ( spec_varme_kap * bromsskiva_massa);

    % Värmeledning via konvektion E = h * A * (T1-T2)
    E_konvektion = konvektion_koefficent * bromsskiva_area * ( temperatur(i-1) - omgivning_temp ) ;
    heat_lost = E_konvektion * dt / (spec_varme_kap * bromsskiva_massa); 
    
    % Uppdaterar temperatur
    temperatur(i) = temperatur(i-1) + heat_generated - heat_lost;
    
    % Uppdaterar heat map
    heat_map = linspace(temperatur(i), 0, 100)';

% kollar om turbinen brinner upp
    if temperatur(i-1) > 800
        smoke_idx = mod(i,length(smoke_Array));
        if smoke_idx == 0, smoke_idx=1; end
        smoking_bild = smoke_Array{smoke_idx};
        smoking_alpha = smoke_alpha_Array{smoke_idx};
        image(smoking_bild,'Parent',ax10, 'AlphaData',smoking_alpha);
        axis(ax10,'off')
    end


% Rörelsemängden   

    % beräknar generatorns/turbins/luftens friktionsmomentet utifrån linjär modell
    friktion_moment = turbin_friktion * abs(w(i-1))  *-1*sign(vind_moment(i));

    % beräknar momentsumman
    total_moment(i) = vind_moment(i) + gear_box_ratio * broms_moment(i) + friktion_moment; 
    
            % kollar P-bromsen ( oviktigt ) 
            if Parkerings_broms_knapp.Value 
                if abs( Ang_momentum(i-1) ) <  100
                    total_moment(i) = 0;
                else , olycka(ax8, fail_Array, Parkerings_broms_knapp); break , end, end

    % integrerar momentet i tiden för att få rörelsemängdsmomentet
    Ang_momentum(i) = Ang_momentum(i-1) + total_moment(i)*dt ;
        
    % Beräknar vinkelhastigheten utifrån röreslemängdens och tröghetens moment
    w(i) = Ang_momentum(i)/I;
    
    if w(i) < 10^(-4) || ~isfinite(w(i))
        w(i) = 0;
    end
    if i>11
    if all(w(i-10:i)<0.1 ), Ang_momentum(i)=0; end, end

% kollar om turbinens sprängs

    % om för hög hastighet
    if abs(w(i)) > 6 % rad/s
        olycka(ax8, fail_Array, Parkerings_broms_knapp) , break
    end


% updaterar alla plots 
    imagesc(ax1,heat_map);
    colormap(ax1,'jet');
    colorbar;
    caxis(ax1,[0, 100]);
    title(ax1,'Bromskiva',FontSize=12);
   
    plot(ax2,tid(1:i), temperatur(1:i),LineWidth=2,Color='r');
    xlabel(ax2,'Tid (s)');
    s = 'Bromsskiva temperatur: '+ string(round(temperatur(i))) +' (°C)';
    title(ax2,s,FontSize=12);

    plot(ax3,tid(1:i), -1*broms_moment(1:i),LineWidth=2);
    xlabel(ax3,'Tid (s)');
    ylabel(ax3,'Nm');
    title(ax3,'Broms-Moment',FontSize=12);

    plot(ax32, tid(1:i), Ang_momentum(1:i) ,LineWidth=2,Color='#4b248c')
    title(ax32,'Rörelsemängdens moment',FontSize=12)
    xlabel(ax32,'Tid (s)');
    ylabel(ax32,'kg m^2/s');
    
    plot(ax4,tid(1:i),friktionstal(1:i),LineWidth=2);
    title(ax4,'Friktionstal bromsskiva: '+string(round(friktionstal(i),1)),FontSize=12);
    ylim(ax4,[0,1])

    plot(ax11,tid(1:i),TSR_vec(1:i),LineWidth=2);
    title(ax11,'Tip-Speed-ratio (λ)',FontSize=10);
    ylim(ax11,[-0.1,11])
    plot(ax12,tid(1:i),Cp_vec(1:i),LineWidth=2,Color='#4b248c');
    title(ax12,'Power coefficent (C_p) ',FontSize=10);
    ylim(ax12,[0,0.6])


    plot(ax5,tid(1:i),vind_hastighet(1:i),LineWidth=1,DisplayName='Vindhastighet (m/s)' )
    hold(ax5,"on")
    plot(ax5,tid(1:i),10^-6*vind_Effekt(1:i),LineWidth=1,DisplayName='Effekt (MW)',Color='green' )
    plot(ax5, tid(1:i), w(1:i) ,LineWidth=1,DisplayName='ω (rad/s)')

    hold(ax5,'off')
    title(ax5,'Vindhastighet, effekt, och vinkelhastighet',FontSize=12);
    legend(ax5,'Location', 'northwest');


% storm
    if vind_hastighet(i) > 24
         storm_idx = mod(i,numel(storm_Array))+1;
         if storm_idx == 0, storm_idx = 1; end
     
         storm_bild = storm_Array{storm_idx};
         image(storm_bild,'Parent',ax6)

         image(stolpe,'Parent',ax7, 'AlphaData',stolpe_alpha)
    else
         image(bg_bild,'Parent',ax6)
         axis(ax6,'off')
    end


% målar turbinen
    % theta förändras lite olika beroende av w pga låg fps
     if abs(w(i))< 2
     theta = theta - w(i)*dt ;
     elseif abs(w(i)) <3
         theta = theta - pi/3;
     else
         theta = theta - 5*pi/6;
    end
    % snabb turbin
    bild_idx = theta_till_idx(theta,dpf);
    bild = turbin_array{bild_idx};
    image(bild,'Parent',ax8,'AlphaData',turbin_bild_data{bild_idx})

    if abs(w(i)) > 4.5 
        bild2_idx =  theta_till_idx(theta+5*pi/3,dpf2);
        bild2 = snabb_turbin_array{bild2_idx};
        turbin2 = image(bild2,'Parent',ax9,'AlphaData',0.005*snabb_turbin_bild_data{bild2_idx});
    else
       if exist('turbin2','var'), delete(turbin2), end
    end

    axis(ax1,'off')
    axis(ax6,'off')
    axis(ax7,'off')
    axis(ax8,'off')
    axis(ax9,'off')
    axis(ax10,'off')


    drawnow

% uppdaterar GUI-element
    set(broms_label, 'String', sprintf('Bromskraft (MN): %.2f', 10^(-6)*F_broms));
    s1 = 'Vindstyrka: '+ string( round( vind_hastighet(i),1 ) ) + ' m/s';
    set(vind_label, 'String', sprintf(s1));
    omega_string = 'Varv per sekund: ' + string( round(w(i-1)/(2*pi),2) ); 
    set(omega_label, 'String', sprintf(omega_string));

    if vind_hastighet(i) < 4.8 && vind_hastighet(i) > 3
        info_string = 'CUT-IN-vind:\nSläpp bromsen!';
        info_color = 'cyan';
    elseif vind_hastighet(i) < 25.5 && vind_hastighet(i) > 23
        info_string = 'CUT-OUT-vind:\nBromsa!';
        info_color = 'yellow';
    elseif vind_hastighet(i) > 25.5 && w(i) ~= 0
        info_string = 'VARNING! \nSTORM!  \nBROMSA!!';
        info_color = 'red';
    else
        info_string = '';
        info_color = 'white';
    end
    set(info_label, 'String', sprintf(info_string));
    set(info_label, 'BackgroundColor', info_color);


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = diskret_funktion(Y,x,k,lower_limit)
% k är antalet elemenet mellan funktionsvärden för
% heltalsargument i Y-vektorn
% lower_limit är funktionsvärdet då x<1
if x < 1
    y = lower_limit;
elseif x > numel(Y)/k
    y = Y(end);
else
    idx = k * round(x, k/10);
    if idx ~= 0 && isfinite( idx )
        y = Y( idx );
    else
    y = lower_limit;
    end
end
end


function idx = theta_till_idx(theta,dpf)
    idx = round(  mod(rad2deg(theta),360)/dpf   );
    if idx == 0 
        idx = 1; 
    end 
end

function lambda = TSR(v,w,r)
    if v ~= 0
        lambda = w * r / v ;
    else
        lambda = 0; 
    end
end

function my = my(temp)

if temp < 600
    my = 0.3 + 0.0003 * temp;
else 
    my = 0.96 - 0.0008 * temp;
end
if my<0, my = 0; end

end

function Parkeringsbroms(src,event)

button_state = src.Value;
        
        if button_state
            %src.String = 'ON';
            src.BackgroundColor = 'green';
        else
            %src.String = 'OFF';
            src.BackgroundColor = 'white';
        end
end



function olycka(ax8, fail_Array, Parkerings_broms_knapp)
%disp('olycka')

if Parkerings_broms_knapp.Value
j=11; else j=1; end
 
for i=j:numel(fail_Array)
    fail_bild = fail_Array{i};
    image(fail_bild,'Parent',ax8)
    axis(ax8,'off')
    drawnow
end
text_label = uicontrol( 'Style', 'text', ...
                        'String', sprintf('GAME OVER'), ...
                        'Position', [20,600,300,70], 'FontSize',30,'FontWeight','bold');
end

