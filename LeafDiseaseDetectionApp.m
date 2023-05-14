classdef LeafDiseaseDetectionApp < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure         matlab.ui.Figure
        UploadButton     matlab.ui.control.Button
        GrayscaleAxes    matlab.ui.control.UIAxes
        AdaptiveHistAxes matlab.ui.control.UIAxes
        OutputTextArea   matlab.ui.control.TextArea
    end

    % Callbacks for app components
    methods (Access = private)

        % Button pushed function: UploadButton
        function UploadButtonPushed(app, ~)
            % Open file dialog to choose an image file
            [file, path] = uigetfile({'*.jpg;*.jpeg;*.png','Image Files'}, 'Choose an Image');
            
            % Check if a file was selected
            if isequal(file,0)
                return;
            end
            
            % Load the image using imread
            image = imread(fullfile(path, file));

            % Convert the image to grayscale
            grayscale = rgb2gray(image);

            % Apply adaptive histogram equalization
            adaptive_hist = adapthisteq(grayscale);

            % Display the grayscale and adaptive histogram images
            imshow(grayscale, 'Parent', app.GrayscaleAxes);
            imshow(adaptive_hist, 'Parent', app.AdaptiveHistAxes);

            % Process the image and determine the disease and cure (dummy values for demonstration)
            disease_name = 'Sample Disease';
            cure = 'Sample Cure';

            % Update the output text area
            app.OutputTextArea.Value = sprintf('Disease: %s\nCure: %s', disease_name, cure);
        end
    end

    % App initialization and construction
    methods (Access = private)
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'Leaf Disease Detection';

            % Create UploadButton
            app.UploadButton = uibutton(app.UIFigure, 'push');
            app.UploadButton.ButtonPushedFcn = createCallbackFcn(app, @UploadButtonPushed, true);
            app.UploadButton.Position = [290 430 60 22];
            app.UploadButton.Text = 'Upload';

            % Create GrayscaleAxes
            app.GrayscaleAxes = uiaxes(app.UIFigure);
            title(app.GrayscaleAxes, 'Grayscale Image')
            app.GrayscaleAxes.Position = [50 170 240 240];

            % Create AdaptiveHistAxes
            app.AdaptiveHistAxes = uiaxes(app.UIFigure);
            title(app.AdaptiveHistAxes, 'Adaptive Histogram Image')
            app.AdaptiveHistAxes.Position = [350 170 240 240];

            % Create OutputTextArea
            app.OutputTextArea = uitextarea(app.UIFigure);
            app.OutputTextArea.Position = [50 50 540 100];
            app.OutputTextArea.Value = '';

        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = LeafDiseaseDetectionApp

            % Create and configure components
            createComponents(app)

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end
end

% Call the app constructor to create and run the app
app = LeafDiseaseDetectionApp;