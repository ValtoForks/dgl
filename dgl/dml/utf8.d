module dgl.dml.utf8;

/*
 * Simple and pretty fast UTF-8 decoder
 */

enum UTF8_END = -1;
enum UTF8_ERROR = -2;

struct UTF8Decoder
{
    size_t index = 0;
    int character = 0;
    int b = 0;
    string input;

    int get()
    {
        if (index >= input.length)
            return UTF8_END;
        auto c = input[index] & 0xFF;
        index++;
        return c;
    }

    int cont()
    {
        int c = get();
        return ((c & 0xC0) == 0x80) ? (c & 0x3F): UTF8_ERROR;
    }

    this(string str)
    {
        input = str;
    }

    int decodeNext()
    {
        int c;  // the first byte of the character
        int r;  // the result

        if (index >= input.length)
            return index == input.length ? UTF8_END : UTF8_ERROR;

        b = index;
        character++;
        c = get();

        // Zero continuation (0 to 127)
        if ((c & 0x80) == 0)
            return c;

        // One continuation (128 to 2047)
        if ((c & 0xE0) == 0xC0)
        {
            int c1 = cont();
            if (c1 >= 0)
            {
                r = ((c & 0x1F) << 6) | c1;
                return r >= 128 ? r : UTF8_ERROR;
            }
        }
        // Two continuation (2048 to 55295 and 57344 to 65535)
        else if ((c & 0xF0) == 0xE0)
        {
            int c1 = cont();
            int c2 = cont();
            if ((c1 | c2) >= 0)
            {
                r = ((c & 0x0F) << 12) | (c1 << 6) | c2;
                return r >= 2048 && (r < 55296 || r > 57343) ? r : UTF8_ERROR;
            }
        }
        // Three continuation (65536 to 1114111)
        else if ((c & 0xF8) == 0xF0)
        {
            int c1 = cont();
            int c2 = cont();
            int c3 = cont();
            if ((c1 | c2 | c3) >= 0)
            {
                return (((c & 0x0F) << 18) | (c1 << 12) | (c2 << 6) | c3) + 65536;
            }
        }

        return UTF8_ERROR;
    }
}

