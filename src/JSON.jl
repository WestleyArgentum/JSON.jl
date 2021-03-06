module JSON

export parse,
       print_to_json, # Prints a compact (no extra whitespace or identation)
                      # JSON representation
       to_json # Gives a compact JSON representation as a String

include("Parser.jl")
function parse(strng::String)
  Parser.parse(strng)
end

function print_to_json(io::IO, s::String)
    print(io, '"')
    print_escaped(io, s, "\"")
    print(io, '"')
end

print_to_json(io::IO, s::Union(Integer, FloatingPoint)) = print(io, s)

print_to_json(io::IO, n::Nothing) = print(io, "null")

print_to_json(io::IO, b::Bool) = print(io, b ? "true" : "false")

function print_to_json(io::IO, a::Associative)
    print(io, "{")
    first = true
    for (key, value) in a
        if first 
            first = false
        else
            print(io, ",")
        end
        print(io, "\"$key\":")
        print_to_json(io, value)
    end
    print(io, "}") 
end

function print_to_json(io::IO, a::AbstractVector)
    print(io, "[")
    if length(a) > 0
        for x in a[1:end-1]
            print_to_json(io, x)
            print(io, ",")
        end
        print_to_json(io, a[end])
    end
    print(io, "]")
end

function print_to_json(io::IO, a)
    print(io, "{")

    range = typeof(a).names
    if length(range) > 0
        print(io, "\"", range[1], "\":")
        print_to_json(io, a.(range[1]))

        for name in range[2:end]
            print(io, ",")
            print(io, "\"", name, "\":")
            print_to_json(io, a.(name))
        end
    end

    print(io, "}")
end

# Default to printing to STDOUT
print_to_json{T}(a::T) = print_to_json(OUTPUT_STREAM, a)

to_json(a) = sprint(print_to_json, a)

function determine_bracket_type(io::IO)
    open_bracket = nothing
    close_bracket = nothing

    while open_bracket == nothing
        c = read(io, Char)
        if c == '{'
            open_bracket = '{'
            close_bracket = '}'
        elseif c == '['
            open_bracket = '['
            close_bracket = ']'
        end
    end

    return (open_bracket, close_bracket)
end

function parse(io::IO)
    open_bracket, close_bracket = determine_bracket_type(io)
    num_brackets_needed = 1

    obj = IOBuffer()
    write(obj, open_bracket)

    while num_brackets_needed > 0
        c = read(io, Char)
        write(obj, c)

        if c == open_bracket
            num_brackets_needed += 1
        elseif c == close_bracket
            num_brackets_needed -= 1
        end
    end

    JSON.parse(takebuf_string(obj))
end

end
