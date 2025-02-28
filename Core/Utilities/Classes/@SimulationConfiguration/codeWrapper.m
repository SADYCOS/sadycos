function varargout = codeWrapper(the_function, the_message)

arguments
    the_function (1,1) function_handle {mustBeNullaryFunctionHandle}
    the_message (:,:) {mustBeTextScalar}
end

the_message_str = string(the_message);

fprintf('SADYCOS >>> %s\n', the_message_str); % Display the start message
start_time = tic; % Start the timer

% Execute the user-provided function and capture outputs
try
    [varargout{1:nargout}] = the_function();
catch ME
    elapsed_time = toc(start_time); % Calculate elapsed time
    fprintf('SADYCOS >>> ...failed (%.4f s)\n', elapsed_time); % Print failure message
    rethrow(ME); % Re-throw the error to the user
end

elapsed_time = toc(start_time); % Calculate elapsed time
fprintf('SADYCOS >>> ...done (%.4f s)\n', elapsed_time); % Display the end message


end

function mustBeNullaryFunctionHandle(a)

    try
        mustBeA(a, 'function_handle');
    catch ME
        throwAsCaller(MException("mustBeNullaryFunctionHandle:notFunctionHandle", "Input must be a function handle."))
    end

    if nargin(a) ~= 0
        throwAsCaller(MException("mustBeNullaryFunctionHandle:notNullary", "Input must be a handle of a function that takes no arguments."))
    end

end

