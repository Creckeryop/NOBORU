FONT    = Font.load("app0:roboto.ttf")
FONT32  = Font.load("app0:roboto.ttf")
Font.setPixelSizes(FONT32, 32)

MANGA_WIDTH     = 200
MANGA_HEIGHT    = math.floor(MANGA_WIDTH * 1.5)

GlobalTimer = Timer.new()

PI = 3.14159265359

function CreateManga(Name, Link, ImageLink, ParserID)
    return {Name = Name, Link = Link, ImageLink = ImageLink, ParserID = ParserID}
end
