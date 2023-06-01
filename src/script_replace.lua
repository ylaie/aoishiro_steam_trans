require( "lfs" )

package.path = package.path ..';..\\?.lua' 

ExecuteTime = os.date()
ShortTime = tostring( ExecuteTime ):gsub( "/", "" ):gsub( ":", "" ):gsub( " ", "")
FileInfo = require( "../zh_cn_text/files-info" )
ScriptDir = "../SCRIPT/AS_ja_jp"
ScriptList = {}
Log = io.open( "../output/" .. ShortTime .. ".log", "w" )

function PrintAndLog( mes )
  if string.find( mes, "\n", -1 ) then
    mes = mes:sub(1, -2)
  end
  print( mes )
  Log:write( mes .. "\n" )
end

function SearchDir( dirPath, list )
  for file in lfs.dir( dirPath ) do
    if file ~= "." and file ~= ".." then
      local filePath = dirPath..'/'..file
      if lfs.attributes( filePath ).mode == "directory" then
        SearchDir( filePath, list )
      else
        PrintAndLog( filePath )
        if list ~= nil then
          table.insert( list, filePath )
        end
      end
    end
  end
end

function SearchTrans ( scriptName )
  for _, scriptInfo in ipairs( FileInfo ) do
    if scriptInfo[2] == scriptName then
      return { scriptInfo[3], scriptInfo[4], scriptInfo[5] }
    end
  end
end

PrintAndLog( "Searching scripts..." )
SearchDir( ScriptDir, ScriptList )

for _, scriptPath in ipairs( ScriptList ) do
  local scriptName =
    string.sub(
      scriptPath,
      1-scriptPath:reverse():find( "/" )
    )
  local info = SearchTrans( scriptName )
  local outDir = string.gsub( string.sub( scriptPath, 1, -scriptName:len()-2 ), "SCRIPT/AS_ja_jp", "output/SCRIPT/AS_zh_cn" )

  PrintAndLog( "Attempt to replace " .. scriptName )
  if info ~= nil then
    PrintAndLog( "Translation in " .. info[1] .. " " .. info[2] .. " " .. info[3] )

    -- In POSIX
    -- os.execute( "mkdir -p " .. outDir )
    if os.execute( "mkdir " .. string.gsub( outDir, "/", "\\" ) ) then
      PrintAndLog( "mkdir " .. outDir)
    end

    local sourceIO = io.open( scriptPath, "r" )
    local outIO = io.open( outDir.. "/" .. scriptName, "w+" )
    local cacheStr = ""
    local content = ""
    local translations = require( "../zh_cn_text/st" .. string.format( "%03u", info[1] ) .. "-u8" )[info[2]]

    if sourceIO == nil or outIO == nil then
      PrintAndLog( "IO error!" )
      if sourceIO ~= nil then
        sourceIO:close()
      end
      if outIO ~= nil then
        outIO:close()
      end
      goto continue
    end

    for line in sourceIO:lines( "L" ) do
      content = ""

      -- WIN_MES_*(NAME, __, __, __){
      -- }
      if line:match( "WIN_MES_" ) then
        PrintAndLog( line )
          cacheStr = sourceIO:read( "L" )
          while cacheStr:match( "}" ) == nil do
            content = content .. cacheStr
            cacheStr = sourceIO:read( "L" )
          end
        PrintAndLog( content .. cacheStr .. "=========>>")

          local characterName = line:match( "[(].-[,]" ):sub( 2, -2 )
          for _, text in ipairs(translations) do
            if characterName == text[3] then
              if text[5] ~= nil then
                characterName = text[5]
              else
                PrintAndLog( "Translation no found!" )
              end
              break
            end
          end
          line = line:gsub( "[(].-[,]", "(" .. characterName .. "," )
        PrintAndLog( line )
          content = content:gsub( "\n", "#cr0" ):sub( 1 , -5 )
          for _, text in ipairs(translations) do
            if content == text[3] then
              if text[5] ~= nil then
                content = text[5]
              else
                PrintAndLog( "Translation no found!" )
              end
              break
            end
          end
          content = content:gsub( "#cr0", "\n" ) .. "\n"
        PrintAndLog( content .. cacheStr .. "\n")

        outIO:write( line .. content ..  cacheStr )
      -- WIN_MES(){
      -- }
      elseif line:match( "WIN_MES" ) then
        PrintAndLog( line )
          cacheStr = sourceIO:read( "L" )
          while cacheStr:match( "}" ) == nil do
            content = content .. cacheStr
            cacheStr = sourceIO:read( "L" )
          end
        PrintAndLog( content .. cacheStr .. "=========>>")

        PrintAndLog( line )
          content = content:gsub( "\n", "#cr0" ):sub( 1 , -5 )
          for _, text in ipairs(translations) do
            if content == text[3] then
              if text[5] ~= nil then
                content = text[5]
              else
                PrintAndLog( "Translation no found!" )
              end
              break
            end
          end
          content = content:gsub( "#cr0", "\n" ) .. "\n"
        PrintAndLog( content .. cacheStr .. "\n")

        outIO:write( line .. content ..  cacheStr )
      -- WIN_SELECT(){
      -- }
      elseif line:match( "WIN_SELECT" ) then
        PrintAndLog( line )
        outIO:write( line )
          cacheStr = sourceIO:read( "L" )
          while cacheStr:match( "}" ) == nil do
            content = cacheStr
            PrintAndLog( content .. "=========>>")
              content = content:gsub( "\n", "#cr0" ):sub( 2 , -5 )
              for _, text in ipairs(translations) do
                if content == text[3] then
                  if text[5] ~= nil then
                    content = text[5]
                  else
                    PrintAndLog( "Translation no found!" )
                  end
                  break
                end
              end
              content = "	" .. content:gsub( "#cr0", "\n" ) .. "\n"
              outIO:write( content )
            PrintAndLog( content .. "\n" )
            cacheStr = sourceIO:read( "L" )
          end
        outIO:write( cacheStr )
        PrintAndLog( cacheStr )
      -- Log_MesAdd(){
      -- }
      elseif line:match( "Log_MesAdd" ) then
        PrintAndLog( line )
          cacheStr = sourceIO:read( "L" )
          while cacheStr:match( "}" ) == nil do
            content = content .. cacheStr
            cacheStr = sourceIO:read( "L" )
          end
        PrintAndLog( content .. cacheStr .. "=========>>")

        PrintAndLog( line )
          content = content:gsub( "\n", "#cr0" ):sub( 1 , -5 )
          for _, text in ipairs(translations) do
            if content == text[3] then
              if text[5] ~= nil then
                content = text[5]
              else
                PrintAndLog( "Translation no found!" )
              end
              break
            end
          end
          content = content:gsub( "#cr0", "\n" ) .. "\n"
        PrintAndLog( content .. cacheStr .. "\n")

        outIO:write( line .. content ..  cacheStr )
      else
        outIO:write( line )
      end
    end

    io.close( sourceIO )
    io.close( outIO )
  else
    PrintAndLog( "No translation info!" )
  end
::continue::
end

PrintAndLog( ExecuteTime )
