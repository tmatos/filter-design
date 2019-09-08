
% fdatool
% Filter Design Tool
% by: Tiago Matos

function fdatool(arg)

  isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;

  if(isOctave)
    pkg load signal
  endif


  %% DADOS DEFAULT DO FILTRO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  n = 10;
  w = 0.5;
  type = 'low';
  window = 'default'
  noscale = false;

  Fs = 48000;
  Apass = 1;
  Astop = -80;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % ajudas:
  % -------
  % https://wiki.octave.org/Uicontrols   (SUPER)
  % https://octave.org/doc/v4.2.0/Figure-Properties.html

  LARGURA = 750;
  ALTURA = 500;

  % create figure without a default toolbar
  h_fig = figure('Visible','off',
                 'numbertitle', 'off',
                 'toolbar', 'none',
                 %'menubar', 'none',,
                 'position',[250 100 LARGURA ALTURA],
                 'Name', 'Filter Designer',
                 'resizefcn', 'disp("TODO: callback para resize")');
  clf;

  % ajuda:
  % https://octave.org/doc/v4.2.2/Uitoolbar-Properties.html#Uitoolbar-Properties
  % https://octave.org/doc/v4.2.2/Uipushtool-Properties.html#Uipushtool-Properties

  % create empty toolbar
  tbar = uitoolbar (h_fig);

  % create a 19x19x3 black square
  img=zeros(19,19,3);

  icon = ones(19,19,3) * 0.7;

  tb10 = uitoggletool(tbar,
                      'cdata',
                      icon,
                      'separator','on',
                      'clickedcallback','msgbox("hehe")');
  tb11 = uitoggletool(tbar,
                      'cdata',
                      icon.-0.1,
                      'separator','on');
  tb20 = uitoggletool(tbar,
                      'cdata',
                      icon.-0.2);

  img_spectro = ones(100,150,3);


  %% PANEL ---------------------------------------------------------------------

  pnlFiltInfo = uipanel ('title', 'Current Filter Information',
                         %'position', [.25 .25 .5 .5]);
                         'position', [.0 .5 .25 .5]);

  COLOR_BLUE = [0.25 0.25 0.85];

  lbl1 = uicontrol('parent',  pnlFiltInfo,
                   'style', 'text',
                   'string', 'Structure:',
                   'foregroundcolor', COLOR_BLUE,
                   'position',[15 175 100 25]);

  lbl2 = uicontrol('parent',  pnlFiltInfo,
                   'style', 'text',
                   'string', 'Order:',
                   'foregroundcolor', COLOR_BLUE,
                   'position',[15 150 100 25]);

  lbl3 = uicontrol('parent',  pnlFiltInfo,
                   'style', 'text',
                   'string', 'Stable:',
                   'foregroundcolor', COLOR_BLUE,
                   'position',[15 125 100 25]);

  lbl4 = uicontrol('parent',  pnlFiltInfo,
                   'style', 'text',
                   'string', 'Source:',
                   'foregroundcolor', COLOR_BLUE,
                   'position',[15 100 100 25]);

  % add two buttons to the panel
  b1 = uicontrol ('parent', pnlFiltInfo,
                  'string', 'Store Filter ...',
                  'position',[18 50 150 25],
                  'callback','msgbox("Ainda falta fazer...", "Oops!")');

  b2 = uicontrol ('parent', pnlFiltInfo,
                  'string', 'Filter Manager ...',
                  'position',[18 10 150 25],
                  'callback','disp("TODO")');



  %% PANEL ---------------------------------------------------------------------

  pnlFiltSpecsFig = uipanel ('title', 'Filter Specifications',
                   'position', [.25 .5 .75 .5]);

  imgSpec = uicontrol('parent',  pnlFiltSpecsFig,
                      'style', 'text',
                      'string', '__________________',
                      'position',[20 50 520 150],
                      'backgroundcolor', [1 1 1]);

  lblTest = uicontrol('parent',  pnlFiltSpecsFig,
                      'style', 'text',
                      'string', 'f (Hz)',
                      'position',[500 10 50 36]);



  %% PANEL ---------------------------------------------------------------------

  pnlResponseType = uipanel ('title', 'Response Type',
                             'position', [.0 .1 .25 .4]);

  % create a button group
  gp1 = uibuttongroup (pnlResponseType,
                       'Position', [ 0 0 1 1]);
                       %'SelectionChangedFcn', @b_resptype_selection); % not supported?
  
  % create a buttons in the group
  rb11 = uicontrol(gp1,
                   'style', 'radiobutton',
                   'string', 'Low Pass',
                   "value", 1,
                   'Position', [ 10 130 150 30 ],
                   'callback','type = "low"');
  rb12 = uicontrol(gp1,
                   'style', 'radiobutton', ...
                   'string', 'High Pass', ...
                   'Position', [ 10 100 150 30 ],
                   'callback','type = "high"');
  rb13 = uicontrol(gp1,
                   'style', 'radiobutton', ...
                   'string', 'Band Pass', ...
                   'Position', [ 10 70 150 30 ],
                   'callback','type = "band_pass"');
  rb14 = uicontrol(gp1,
                   'style', 'radiobutton', ...
                   'string', 'Band Stop', ...
                   'Position', [ 10 40 150 30 ],
                   'callback','type = "band_stop"');
  
  # TODO
  function b_resptype_selection(source,event)
       disp(['Previous: ' event.OldValue.String]);
       disp(['Current: ' event.NewValue.String]);
       disp('------------------');
  end

                   
  pnlFilterOrder = uipanel ('title', 'Filter Order',
                             'position', [.25 .1 .25 .4]);

  % create a button group
  gp2 = uibuttongroup (pnlFilterOrder, 'Position', [ 0 0 1 1]);
  
  % create a buttons in the group
  rb21 = uicontrol(gp2,
                  'style', 'radiobutton', ...
                  'string', 'Specify Order:', ...
                   "value", 1,
                  'selected', 'on',
                  'Position', [ 10 100 150 30 ]);
  rb22 = uicontrol(gp2,
                  'style', 'radiobutton', ...
                  'string', 'Minimum Order', ...
                  'Position', [ 10 70 150 30 ]);

  edtOrder = uicontrol(gp2,
                       'style', 'edit',
                       'string', num2str(n),
                       'Position', [ 135 101 30 25 ]);



  %% PANEL ---------------------------------------------------------------------

  pnlFreqSpecs = uipanel ('title', 'Frequency Specifications',
                          'position', [.5 .1 .25 .4]);

  lblPop1 = uicontrol('parent',  pnlFreqSpecs,
                      'style', 'text',
                      'string', 'Units:',
                      'position',[5 150 50 20]);

  pop1 = uicontrol(pnlFreqSpecs,
                  'style', 'popupmenu',
                  'string', ['Hz'; 'kHz'],
                  'position',[60 145 100 30]);

  lblFs = uicontrol('parent',  pnlFreqSpecs,
                    'style', 'text',
                    'string', 'Fs:',
                    'position',[15 115 50 20]);

  edtFs = uicontrol('parent',  pnlFreqSpecs,
                    'style', 'edit', ...
                    'string', '48000', ...
                    'Position', [ 70 110 90 25 ]);

  lblFpass = uicontrol('parent',  pnlFreqSpecs,
                       'style', 'text',
                       'string', 'Fpass:',
                       'position',[5 85 50 20]);

  edtFpass = uicontrol('parent',  pnlFreqSpecs,
                       'style', 'edit', ...
                       'string', '9600', ...
                       'Position', [ 70 80 90 25 ]);

  lblStop = uicontrol('parent',  pnlFreqSpecs,
                       'style', 'text',
                       'string', 'Fstop:',
                       'position',[5 55 50 20]);

  edtStop = uicontrol('parent',  pnlFreqSpecs,
                       'style', 'edit', ...
                       'string', '11600', ...
                       'Position', [ 70 50 90 25 ]);



  %% PANEL ---------------------------------------------------------------------

  pnlMagSpecs = uipanel ('title', 'Magnitude Specifications',
                          'position', [.75 .1 .25 .4]);

  lblPop2 = uicontrol('parent',  pnlMagSpecs,
                      'style', 'text',
                      'string', 'Units:',
                      'position',[5 150 50 20]);

  pop2 = uicontrol(pnlMagSpecs,
                  'style', 'popupmenu',
                  'string', ['dB'; 'B'],
                  'position',[60 145 100 30]);

  lblApass = uicontrol('parent',  pnlMagSpecs,
                       'style', 'text',
                       'string', 'Apass:',
                       'position',[5 110 50 20]);

  edtApass = uicontrol(pnlMagSpecs,
                       'style', 'edit', ...
                       'string', '1', ...
                       'Position', [ 70 105 90 25 ]);

  lblAstop = uicontrol('parent',  pnlMagSpecs,
                       'style', 'text',
                       'string', 'Astop:',
                       'position',[5 75 50 20]);

  edtAstop = uicontrol(pnlMagSpecs,
                       'style', 'edit', ...
                       'string', '80', ...
                       'Position', [ 70 70 90 25 ]);

  %% PANEL EMBAIXO--------------------------------------------------------------

  pnlBottom = uipanel ('position', [.0 .0 1 .1]);

  btnDesign = uicontrol ('parent', pnlBottom,
                         'string', 'Design Filter',
                         'position',[ (LARGURA-150)/2 10 150 25],
                         'tooltipstring', 'faz a porra toda',
                         'callback', { @disp_dados, n, w, type, guidata(h_fig,edtOrder) });
                         %'callback','dialogtest');

  %% ---------------------------------------------------------------------------


  m1 = uimenu ('parent',h_fig,
               'label','Analysis',
               'callback','disp("TODO")');

  m2 = uimenu ('parent',h_fig,
               'label','Targets',
               'callback','disp("TODO")');


  set(h_fig, 'visible', 'on');


  %% ajudar pra fazer filtro (signal pkg)
  % https://www.allaboutcircuits.com/technical-articles/design-of-fir-filters-design-octave-matlab/
  % https://octave.sourceforge.io/signal/function/fir1.html
  % https://octave.sourceforge.io/signal/overview.html


  % set the context menu for the figure
  %set (f, 'uicontextmenu', c);


end


% unused
function update_order(obj)
  % gcbo holds the handle of the control
  % "Return a handle to the object whose callback is currently executing."

  h = guidata(obj); % ??

  if(gcbo == h.edtOrder)

  endif

end


%% callback subfunction (in same file)
function disp_dados (hObject, eventdata, n, wc_norm, type, h_edtOrder )
  n = get(h_edtOrder,'string');
  n = str2num(n);

  n
  wc_norm % default is dimensionless (i. e., w in [0, 1])
  type
  %window
  %noscale

  Fs = 48000;
  fc = wc_norm * (Fs/2);

  h = fir1(n, wc_norm, type);

  figure;
  freqz(h);

  figure;
  stem(h);

  %msgbox('Ainda falta fazer direito...', 'Oops!');
end
